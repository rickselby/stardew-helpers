// Inspired by the brilliant https://github.com/MouseyPounds/stardew-checkup

import { CSRandom } from './cs-random';

$(document).ready(function() {

    // Check for required File API support.
    if (!(window.File && window.FileReader)) {
        document.getElementById('forage-out').innerHTML = '<span class="error">Fatal Error: Could not load the File & FileReader APIs</span>';
        return;
    }

    // Show input field once we know we have File API support
    $('#forage-input-container').show();

    /**
     * When a file is selected...
     */
    $('#forage_file_select').change(function() {
        let file = $(this)[0].files[0],
            reader = new FileReader();

        // Hide any shown maps
        $('#forage-maps').hide();

        reader.onload = function (e) {
            let xmlDoc = $.parseXML(e.target.result),
                farmType = $(xmlDoc).find('whichFarm').text();

            // Set the contents of the output div
            $('#forage-out').html(
                showForageLocations(getForageSpots(xmlDoc), farmType, xmlDoc)
            );

            // Show the forage maps again
            $('#forage-maps').show();

            // Hide the input advice after the first file load
            $('#forage-input-advice').hide();
        };

        reader.readAsText(file);
    });

    /**
     * Get a list of forage spots from the save file
     *
     * @param xmlDoc
     * @returns {Array}
     */
    function getForageSpots(xmlDoc) {
        let locations = [];

        let lookFor = [
            16, // Wild Horseradish
            18, // Daffodil
            20, // Leek
            22, // Dandelion
            88, // Coconut
            90, // Cactus Fruit
            257, // Morel
            259, // Fiddlehead Fern
            281, // Chanterelle
            283, // Holly
            372, // Clam
            392, // Nautilus Shell
            393, // Coral
            394, // Rainbow Shell
            396, // Spice Berry
            397, // Sea Urchin
            398, // Grape
            402, // Sweet Pea
            404, // Common Mushroom
            406, // Wild Plum
            408, // Hazelnut
            410, // Blackberry
            420, // Red Mushroom
            414, // Crystal Fruit
            418, // Crocus
            718, // Cockle
            719, // Mussel
            723, // Oyster
        ];

        // Step through each location in the game
        $(xmlDoc).find('locations > GameLocation').each(function () {
            let map = $(this).children('name').text(),
                location = {
                    'map': map,
                    'spots': []
                };

            // Step through each object in each location...
            $(this).find('objects > item').each(function () {
                // Is this something we want to look for?
                if (lookFor.includes(parseInt($(this).find('parentSheetIndex').text()))) {
                    location.spots.push({
                        'x': $(this).find('tileLocation > X').text(),
                        'y': $(this).find('tileLocation > Y').text(),
                        // Find out which forage is in this location
                        'name': $(this).find('DisplayName').text(),
                    });
                }
            });

            $(this).find('terrainFeatures > item').each(function () {
                if ($(this).find('whichForageCrop').text() === '1') {
                    location.spots.push({
                        'x': $(this).find('tileLocation > X').text(),
                        'y': $(this).find('tileLocation > Y').text(),
                        'name': 'Spring Onion',
                    });
                }
            });

            // If we found forage spots in this location, add the location to the list
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
    function showForageLocations(locations, farmType, xmlDoc) {
        let output = [];
        $.each(locations, function(id, location) {

            output.push($('<h3>').text(getMapName(location.map)));

            $.each(location.spots, function(id, spot) {

                output.push(
                    $('<div>')
                        .addClass('forageMap map')
                        .append(
                            $('<div>')
                                .append(
                                    $('<h4>').text(spot.name),
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
        let maps = {
            BusStop: 'Bus Stop',
            Woods: 'Hidden Forest'
        };

        if (maps.hasOwnProperty(map)) {
            return maps[map];
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
            switch (farmType) {
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

});
