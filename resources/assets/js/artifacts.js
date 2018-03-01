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

        $('#output-container').hide();

        reader.onload = function (e) {
            var output = "",
                xmlDoc = $.parseXML(e.target.result);

            output += showLocations(getArtifactSpots(xmlDoc));

            console.log(output);

            $('#out').html(output);

            $('#output-container').show();
        };

        reader.readAsText(file);
    });

    function getArtifactSpots(xmlDoc) {
        var locations = [];
        $(xmlDoc).find('locations > GameLocation').each(function () {
            var location = {
                'map': $(this).attr('xsi:type'),
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

    function showLocations(locations) {
        var output = "";
        $.each(locations, function(id, location) {
            output += '<h3>' + location.map + '</h3>';
            $.each(location.spots, function(id, spot) {
                output += '<span class="artifactMap"><img src="map/' + location.map + '/' + spot.x + '/' + spot.y + '" /></span>';
            });
        });
        return output;
    }
});
