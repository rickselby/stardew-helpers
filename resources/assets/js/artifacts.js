// Inspired by the brilliant https://github.com/MouseyPounds/stardew-checkup

import { CSRandom } from './cs-random';

$(document).ready(function() {

    // Check for required File API support.
    if (!(window.File && window.FileReader)) {
        document.getElementById('out').innerHTML = '<span class="error">Fatal Error: Could not load the File & FileReader APIs</span>';
        return;
    }

    // Show input field once we know we have File API support
    $('#input-container').show();

    /**
     * When a file is selected...
     */
    $('#file_select').change(function() {
        var file = $(this)[0].files[0],
            reader = new FileReader();

        // Hide any shown maps
        $('#artifact-maps').hide();

        reader.onload = function (e) {
            var xmlDoc = $.parseXML(e.target.result),
                farmType = $(xmlDoc).find('whichFarm').text();

            // Set the contents of the output div
            $('#out').html(
                showLocations(getArtifactSpots(xmlDoc), farmType, xmlDoc)
            );

            // Show the artifact maps again
            $('#artifact-maps').show();

            // Hide the input advice after the first file load
            $('#input-advice').hide();
        };

        reader.readAsText(file);
    });

    /**
     * Get a list of artifact spots from the save file
     *
     * @param xmlDoc
     * @returns {Array}
     */
    function getArtifactSpots(xmlDoc) {
        var locations = [];

        // Step through each location in the game
        $(xmlDoc).find('locations > GameLocation').each(function () {
            var map = $(this).children('name').text(),
                location = {
                    'map': map,
                    'spots': []
                };

            // Step through each object in each location...
            $(this).find('objects > item').each(function () {
                // Add any Artifact Spots to the list of spots for this location
                if ($(this).find('DisplayName').text() === "Artifact Spot") {
                    location.spots.push({
                        'x': $(this).find('tileLocation > X').text(),
                        'y': $(this).find('tileLocation > Y').text(),
                        // Find out which artifact is in this location
                        'artifact': findArtifact(
                            $(this).find('tileLocation > X').text(),
                            $(this).find('tileLocation > Y').text(),
                            map,
                            xmlDoc
                        )
                    });
                }
            });

            // If we found artifact spots in this location, add the location to the list
            if (location.spots.length > 0) {
                locations.push(location);
            }
        });

        return locations;
    }

    /**
     * Take a list of locations and generate HTML to show them
     *
     * @param locations
     * @param farmType
     * @param xmlDoc
     * @returns {jQuery|HTMLElement}
     */
    function showLocations(locations, farmType, xmlDoc) {
        var output = [];
        $.each(locations, function(id, location) {

            output.push($('<h3>').text(getMapName(location.map)));

            $.each(location.spots, function(id, spot) {

                var artifact = $('<h4>').text(spot.artifact.name);
                if (spot.artifact.type === 'Arch' && !artifactsFound(spot.artifact.id, xmlDoc)) {
                    artifact.addClass('artifact-needed');
                }

                output.push(
                    $('<div>')
                        .addClass('artifactMap')
                        .append(
                            $('<div>')
                                .append(
                                    artifact,
                                    $('<img>')
                                        .attr('src', 'map/' + getMapReference(location.map, farmType) + '/' + spot.x + '/' + spot.y)
                                )
                        )
                );
            });
        });

        return output;
    }

    /**
     * Get the map name for display
     *
     * @param map
     * @returns {*}
     */
    function getMapName(map) {
        var artifactMaps = {
            BusStop: 'Bus Stop',
            Woods: 'Hidden Forest'
        }

        if (artifactMaps.hasOwnProperty(map)) {
            return artifactMaps[map];
        } else {
            return map;
        }
    }

    /**
     * Get the correct map for the farm for the current save
     *
     * @param map
     * @param farmType
     * @returns {*}
     */
    function getMapReference(map, farmType) {
        if (map === 'Farm') {
            switch(farmType) {
                case '0':
                    return 'Farm';
                case '1':
                    return 'FarmFishing';
                case '2':
                    return 'FarmForage';
                case '3':
                    return 'FarmMining';
                case '4':
                    return 'FarmCombat';
                default:
                    return 'WHAT';
            }
        } else {
            return map;
        }
    }

    /**
     * Find which artifact will be found in a given spot
     *
     * (GameLocation.cs; digUpArtifactSpot(), approx. line 7618)
     *
     * @param x
     * @param y
     * @param map
     * @param xmlDoc
     * @returns {*}
     */
    function findArtifact(x, y, map, xmlDoc) {
        var uniqueID = $(xmlDoc).find('uniqueIDForThisGame').text(),
            daysPlayed = $(xmlDoc).find('DaysPlayed').text(),
            rng = new CSRandom((parseInt(x) * 2000) + parseInt(y) + parseInt(uniqueID / 2) + parseInt(daysPlayed)),
            objectIndex = -1;

        $.each(objectInformation, function(key, data) {
            if (data.type === "Arch") {
                $.each(data.locations, function(location, chance) {
                    if (map === location && rng.NextDouble() < chance) {
                        objectIndex = key;
                        return false;
                    }
                });
                if (objectIndex !== -1) {
                    return false;
                }
            }
        });

        if (rng.NextDouble() < 0.2 && (map !== 'Farm')) {
            objectIndex = 102;
        }

        if ((objectIndex === 102) && (artifactsFound(102, xmlDoc) >= 21)) {
            objectIndex = 770;
        }

        if (objectIndex !== -1) {
            // do nothing; objectIndex is now set
        } else if (($(xmlDoc).find('currentSeason').text() === 'winter') && (rng.NextDouble() < 0.5) && (map !== 'Desert')) {
            if (rng.NextDouble() < 0.4) {
                objectIndex = 416;
            } else {
                objectIndex = 412;
            }
        } else {
            if (map in locations) {
                $.each(locations[map], function(k, item) {
                    var nextRNG = rng.NextDouble();
                    if (nextRNG <= item.chance) {
                        objectIndex = item.id;
                        if ((item.id === 102) && (artifactsFound(102, xmlDoc) >= 21)) {
                            objectIndex = 770;
                        }
                        return false;
                    }
                })
            }
        }

        return objectInformation[objectIndex];
    }

    /**
     * Get the number of a specific artifact found
     *
     * @param artifactID
     * @param xmlDoc
     * @returns {number}
     */
    function artifactsFound(artifactID, xmlDoc) {
        return parseInt(
            $(xmlDoc).find('player > archaeologyFound key').filter(function () {
                return $.trim($(this).text()) === '' + artifactID;
            }).siblings('value').find('int').first().text()
        );
    }

    /**
     * List of objects that can be found under artifact spots, and their locations and chances
     */
    const objectInformation = {
        96: {id: 96, name: "Dwarf Scroll I", type: "Arch", locations: {}},
        97: {id: 97, name: "Dwarf Scroll II", type: "Arch", locations: {}},
        98: {id: 98, name: "Dwarf Scroll III", type: "Arch", locations: {}},
        99: {id: 99, name: "Dwarf Scroll IV", type: "Arch", locations: {}},
        100: {id: 100, name: "Chipped Amphora", type: "Arch", locations: {Town: .04}},
        101: {id: 101, name: "Arrowhead", type: "Arch", locations: {Mountain: .02, Forest: .02, BusStop: .02}},
        102: {id: 102, name: "Lost Book", type: "asdf", locations: {Town: .05}},
        103: {
            id: 103,
            name: "Ancient Doll",
            type: "Arch",
            locations: {Mountain: .04, Forest: .03, BusStop: .03, Town: .01}
        },
        104: {id: 104, name: "Elvish Jewelry", type: "Arch", locations: {Forest: .01}},
        105: {id: 105, name: "Chewing Stick", type: "Arch", locations: {Mountain: .02, Town: .01, Forest: .02}},
        106: {id: 106, name: "Ornamental Fan", type: "Arch", locations: {Beach: .02, Town: .008, Forest: .01}},
        107: {id: 107, name: "Dinosaur Egg", type: "Arch", locations: {Mine: .01, Mountain: .008}},
        108: {id: 108, name: "Rare Disc", type: "Arch", locations: {UndergroundMine: .01}},
        109: {id: 109, name: "Ancient Sword", type: "Arch", locations: {Forest: .01, Mountain: .008}},
        110: {id: 110, name: "Rusty Spoon", type: "Arch", locations: {Town: .05}},
        111: {id: 111, name: "Rusty Spur", type: "Arch", locations: {Farm: .1}},
        112: {id: 112, name: "Rusty Cog", type: "Arch", locations: {Mountain: .05}},
        113: {id: 113, name: "Chicken Statue", type: "Arch", locations: {Farm: .1}},
        114: {id: 114, name: "Ancient Seed", type: "Arch", locations: {Forest: .01, Mountain: .01}},
        115: {id: 115, name: "Prehistoric Tool", type: "Arch", locations: {Mountain: .03, Forest: .03, BusStop: .04}},
        116: {id: 116, name: "Dried Starfish", type: "Arch", locations: {Beach: .1}},
        117: {id: 117, name: "Anchor", type: "Arch", locations: {Beach: .05}},
        118: {id: 118, name: "Glass Shards", type: "Arch", locations: {Beach: .1}},
        119: {
            id: 119,
            name: "Bone Flute",
            type: "Arch",
            locations: {Mountain: .01, Forest: .01, UndergroundMine: .02, Town: .005}
        },
        120: {
            id: 120,
            name: "Prehistoric Handaxe",
            type: "Arch",
            locations: {Mountain: .05, Forest: .05, BusStop: .05}
        },
        121: {id: 121, name: "Dwarvish Helm", type: "Arch", locations: {UndergroundMine: .01}},
        122: {id: 122, name: "Dwarf Gadget", type: "Arch", locations: {UndergroundMine: .001}},
        123: {
            id: 123,
            name: "Ancient Drum",
            type: "Arch",
            locations: {BusStop: .01, Forest: .01, UndergroundMine: .02, Town: .005}
        },
        124: {id: 124, name: "Golden Mask", type: "Arch", locations: {Desert: .04}},
        125: {id: 125, name: "Golden Relic", type: "Arch", locations: {Desert: .08}},
        126: {
            id: 126,
            name: "Strange Doll",
            type: "Arch",
            locations: {Farm: .001, Town: .001, Mountain: .001, Forest: .001, BusStop: .001, Beach: .001, UndergroundMine: .001}
        },
        127: {
            id: 127,
            name: "Strange Doll",
            type: "Arch",
            locations: {Farm: .001, Town: .001, Mountain: .001, Forest: .001, BusStop: .001, Beach: .001, UndergroundMine: .001}
        },
        330: {id: 330, name: "Clay", type: "Basic -16", locations: {}},
        378: {id: 378, name: "Copper Ore", type: "Basic -15", locations: {}},
        382: {id: 382, name: "Coal", type: "Basic -15", locations: {}},
        384: {id: 384, name: "Gold Ore", type: "Basic -15", locations: {}},
        390: {id: 390, name: "Stone", type: "Basic -16", locations: {}},
        412: {id: 412, name: "Winter Root", type: "Basic -81", locations: {}},
        416: {id: 416, name: "Snow Yam", type: "Basic -81", locations: {}},
        579: {id: 579, name: "Prehistoric Scapula", type: "Arch", locations: {}},
        580: {id: 580, name: "Prehistoric Tibia", type: "Arch", locations: {}},
        581: {id: 581, name: "Prehistoric Skull", type: "Arch", locations: {}},
        582: {id: 582, name: "Skeletal Hand", type: "Arch", locations: {}},
        583: {id: 583, name: "Prehistoric Rib", type: "Arch", locations: {}},
        584: {id: 584, name: "Prehistoric Vertebra", type: "Arch", locations: {}},
        585: {id: 585, name: "Skeletal Tail", type: "Arch", locations: {}},
        586: {id: 586, name: "Nautilus Fossil", type: "Arch", locations: {}},
        587: {id: 587, name: "Amphibian Fossil", type: "Arch", locations: {}},
        588: {id: 588, name: "Palm Fossil", type: "Arch", locations: {}},
        589: {id: 589, name: "Trilobite", type: "Arch", locations: {}},
        770: {id: 770, name: "Mixed Seeds", type: "Seeds -74", locations: {}}
    };

    /**
     * List of locations where artifacts can be found, and  the artifacts and chances
     */
    const locations = {
        Farm: [{id: 382, chance: .05}, {id: 770, chance: .1}, {id: 390, chance: .25}, {id: 330, chance:  1}],
        Desert: [{id: 390, chance: .25}, {id: 330, chance:  1}],
        BusStop: [{id: 584, chance: .08}, {id: 378, chance: .15}, {id: 102, chance: .15}, {id: 390, chance: .25}, {id: 330, chance:  1}],
        Forest: [{id: 378, chance: .08}, {id: 579, chance: .1}, {id: 588, chance: .1}, {id: 102, chance: .15}, {id: 390, chance: .25}, {id: 330, chance:  1}],
        Town: [{id: 378, chance: .2}, {id: 110, chance: .2}, {id: 583, chance: .1}, {id: 102, chance: .2}, {id: 390, chance: .25}, {id: 330, chance:  1}],
        Mountain: [{id: 382, chance: .06}, {id: 581, chance: .1}, {id: 378, chance: .1}, {id: 102, chance: .15}, {id: 390, chance: .25}, {id: 330, chance:  1}],
        Backwoods: [{id: 382, chance: .06}, {id: 582, chance: .1}, {id: 378, chance: .1}, {id: 102, chance: .15}, {id: 390, chance: .25}, {id: 330, chance:  1}],
        Railroad: [{id: 580, chance: .1}, {id: 378, chance: .15}, {id: 102, chance: .19}, {id: 390, chance: .25}, {id: 330, chance:  1}],
        Beach: [{id: 384, chance: .08}, {id: 589, chance: .09}, {id: 102, chance: .15}, {id: 390, chance: .25}, {id: 330, chance:  1}],
        Woods: [{id: 390, chance: .25}, {id: 330, chance:  1}]
    }

});
