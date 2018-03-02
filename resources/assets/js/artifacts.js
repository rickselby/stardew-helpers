// Inspired by the brilliant https://github.com/MouseyPounds/stardew-checkup

$(document).ready(function() {

    // Check for required File API support.
    if (!(window.File && window.FileReader)) {
        document.getElementById('out').innerHTML = '<span class="error">Fatal Error: Could not load the File & FileReader APIs</span>';
        return;
    }

    // Show input field immediately
    $('#input-container').show();

    $('#file_select').change(function() {
        var file = $(this)[0].files[0],
            reader = new FileReader();

        $('#artifact-maps').hide();

        reader.onload = function (e) {
            var output = "",
                xmlDoc = $.parseXML(e.target.result),
                farmType = $(xmlDoc).find('whichFarm').text();

            output += showLocations(getArtifactSpots(xmlDoc), farmType);

            $('#out').html(output);

            $('#artifact-maps').show();
            $('#input-advice').hide();
        };

        reader.readAsText(file);
    });

    function getArtifactSpots(xmlDoc) {
        var locations = [];
        $(xmlDoc).find('locations > GameLocation').each(function () {
            var location = {
                'map': $(this).children('name').text(),
                'spots': []
            };
            $(this).find('objects > item').each(function () {
                if ($(this).find('DisplayName').text() === "Artifact Spot") {
                    location.spots.push({
                        'x': $(this).find('tileLocation > X').text(),
                        'y': $(this).find('tileLocation > Y').text()
                    });
                }
            });
            if (location.spots.length > 0) {
                locations.push(location);
            }
        });
        return locations;
    }

    function showLocations(locations, farmType) {
        var output = "";
        $.each(locations, function(id, location) {
            output += '<h3>' + getMapName(location.map) + '</h3>';
            $.each(location.spots, function(id, spot) {
                output += '<span class="artifactMap"><img src="map/' + getMapReference(location.map, farmType) + '/' + spot.x + '/' + spot.y + '" /></span>';
            });
        });
        return output;
    }

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

    function getMapReference(map, farmType) {
        if (map === 'Farm') {
            console.log(map, farmType);
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

});
