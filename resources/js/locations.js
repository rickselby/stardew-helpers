
$(document).ready(function() {

    let locationSelected = {
        villager: '',
        season: '',
        day: ''
    };

    /**
     * Villagers
     */

    $.each(villagers, function(key, villager) {
        $('#villagers').append(
            $('<img>')
                .attr('src', 'portrait/' + villager)
                .attr('alt', villager)
                .attr('title', villager)
                .attr('data-name', villager)
                .addClass('portrait')
        );
    });

    $('#villagers').find('img').click(function() {
        locationSelected.villager = $(this).attr('data-name');

        $('.portrait-active').removeClass('portrait-active');
        $(this).addClass('portrait-active');

        updateSchedules();
    });

    /**
     * Calendars
     */

    $.each(seasons, function(key, season) {

        let mapName = season + 'Map',
            map = $('<map>').attr('name', mapName);

        $.each(days, function(dayKey, day) {
            map.append(
                $('<area>')
                    .attr('shape', 'rect')
                    .attr('coords', getCoords(day))
                    .attr('alt', day)
                    .attr('title', day)
                    .attr('data-season', season)
                    .attr('data-day', day)
            );
        });

        $('#calendars').append(
            $('<div>')
                .addClass('calendar-container')
                .append(
                    $('<h4>').text(capitalizeFirstLetter(season)),
                    $('<span>')
                        .addClass('calendar')
                        .attr('id', season)
                        .append(
                            $('<img>')
                                .attr('src', 'images/calendar.png')
                                .attr('usemap', '#' + mapName),
                            $('<div>').addClass('calendar-marker')
                        ),
                    map
                )
        );
    });

    $('#calendars').find('area').click(function() {
        locationSelected.day = $(this).attr('data-day');
        locationSelected.season = $(this).attr('data-season');

        $('.calendar-marker').hide();
        $('#' + locationSelected.season).find('.calendar-marker')
            .show()
            .css('left', (7 + (((locationSelected.day - 1) % 7) * 32)))
            .css('top', (37 + (Math.floor((locationSelected.day - 1) / 7) * 32)));

        updateSchedules();
    });

    /**
     * Schedules
     */

    function updateSchedules() {

        $('#possibilities').each(function() {
            $(this).fadeTo(300, 0);
        });

        $('#loading').show();
        $('#possibilities-some').empty();

        $.ajax({
            url: postURL,
            data: {
                'villager': locationSelected.villager,
                'season': locationSelected.season,
                'day': locationSelected.day
            },
            dataType: 'json',
            type: 'post',
            error: function (XMLHttpRequest, textStatus, errorThrown) {

                $('#possibilities-none').show();

                $('#loading').hide();
                $('#possibilities').promise().done(function() {

                    $('#possibilities').each(function () {
                        $(this).fadeTo(300, 1);
                    });

                });
            },
            success: function (data) {

                $('#possibilities-none').hide();

                $('#loading').hide();
                $('#possibilities').promise().done(function() {

                    $('#possibilities-some').append(
                        $('<h4>').addClass('col-xs-12 text-center').text(
                                locationSelected.villager + ': '
                                    + ordinalSuffix(locationSelected.day) + ' of '
                                    + capitalizeFirstLetter(locationSelected.season)
                            )
                    );

                    $.each(filterPossibilities(data.possibilities), function(key, possibility) {

                        var schedule;
                        if (possibility.doubleRain) {
                            schedule = [
                                $('<div>').addClass('col-xs-6')
                                    .attr('style', 'border-right: 1px solid black')
                                    .append(getSchedule(data.schedules[possibility.schedule])),
                                $('<div>').addClass('col-xs-6')
                                    .append(getSchedule(data.schedules[possibility.doubleRainSchedule]))
                            ];
                        } else {
                            schedule = getSchedule(data.schedules[possibility.schedule]);
                        }

                        $('#possibilities-some').append(
                            $('<div>').addClass('panel').addClass(getPossClasses(possibility)).append(
                                $('<div>').addClass('bulletin').append(
                                    $('<div>').addClass('panel-heading').append(
                                        $('<h4>').text(
                                            possibility.extra +
                                            (possibility.doubleRain ? ' (equal chance of either)' : '')
                                        )
                                    ),
                                    schedule
                                )
                            )
                        );
                    });

                    $('#possibilities').each(function () {
                        $(this).fadeTo(300, 1);
                    });

                });
            }
        });
    }

    /**
     * Get the HTML for a schedule
     *
     * @param schedule
     * @returns {jQuery}
     */
    function getSchedule(schedule)
    {
        let list = $('<ul>').addClass('list-group');

        $.each(filterSteps(schedule), function(key, step) {
            list.append(
                $('<li>').addClass('list-group-item').append(
                    formatTime(step.time) + ': ',
                    $('<a>')
                        .attr('href', '#mapModal')
                        .attr('data-toggle', 'modal')
                        .attr('data-target', '#mapModal')
                        .attr('data-map', step.map + '/' + step.x + '/' + step.y)
                        .text(step.location)
                )
            )
        });

        return list;
    }

    /**
     * Filter the possibilities - group multiple rain possiblities together
     *
     * @param possibilities
     * @returns {Array}
     */
    function filterPossibilities(possibilities) {
        let possList = [];
        $.each(possibilities, function(key, possibility) {
            if (possList.length === 0) {
                possList.push(possibility);
            } else {
                if (possibility.rain && possList[possList.length - 1].rain) {
                    possList[possList.length - 1].doubleRain = true;
                    possList[possList.length - 1].doubleRainSchedule = possibility.schedule;
                } else {
                    possList.push(possibility);
                }
            }
        });
        return possList;
    }

    /**
     * Get the correct classes for a possibility
     *
     * @param possibility
     * @returns {string[]}
     */
    function getPossClasses(possibility) {
        if (possibility.doubleRain) {
            return ['col-lg-6 col-md-8 col-sm-12'];
        } else {
            return ['col-lg-3 col-md-4 col-sm-6'];
        }
    }

    /**
     * Filter steps; ignore movement around the same location
     *
     * @param steps
     * @returns {Array}
     */
    function filterSteps(steps) {
        let stepList = [];
        $.each(steps, function(key, step) {
            if (stepList.length === 0) {
                stepList.push(step);
            } else {
                if (stepList[stepList.length - 1].location !== step.location) {
                    stepList.push(step);
                }
            }
        });
        return stepList;
    }

    /**
     * Correctly format a time string
     *
     * @param time
     * @returns {string}
     */
    function formatTime(time) {
        // Pad left with a zero, if necessary
        time = ('0' + time).slice(-4);
        return time.slice(0, 2) + ':' + time.slice(-2);
    }

    /**
     * Modals - set image when opened
     */

    $('#mapModal').on('show.bs.modal', function (event) {
        // Using .data() to get the data-map attribute seems to cache the information, so when the vue app changes
        // the links, we get the old images... Using .attr() doesn't cache anything, so we use that.
        let map = $(event.relatedTarget).attr('data-map');
        $(this).find('IMG').attr('src', 'map/' + map);
    });

    /**
     * Helper functions
     */

    /**
     * Get co-ordinates for each area box with an image map
     *
     * @param day
     * @returns {string}
     */
    function getCoords(day) {
        let dayOfWeek = ((day - 1) % 7); // 0 (Monday) - 6 (Sunday)
        let row = Math.floor((day - 1) / 7); // 0 - 3

        // Each area is 32px square; x offset is 9, y offset is 39
        return '' + ((dayOfWeek * 32) + 9) + ',' +
            ((row * 32) + 39) + ',' +
            ((dayOfWeek * 32) + 41) + ',' +
            ((row * 32) + 71);
    }

    /**
     * Capitalize the first letter of a string
     *
     * @param string
     * @returns {string}
     */
    function capitalizeFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }

    /**
     * Return a number with its ordinal suffix
     *
     * @param val
     * @returns {string}
     */
    function ordinalSuffix(val) {
        let j = val % 10,
            k = val % 100;
        if (j == 1 && k != 11) {
            return val + "st";
        }
        if (j == 2 && k != 12) {
            return val + "nd";
        }
        if (j == 3 && k != 13) {
            return val + "rd";
        }
        return val + "th";
    }
});
