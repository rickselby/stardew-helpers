
/**
 * First we will load all of this project's JavaScript dependencies which
 * includes Vue and other libraries. It is a great starting point when
 * building robust, powerful web applications using Vue and Laravel.
 */

require('./bootstrap');

Vue.component('schedules', require('./components/Schedules.vue'));

window.addEventListener('load', function () {
    const app = new Vue({
        el: '#app'
    });
});

$( document ).ready(function() {

    $('select').change(updateColours);

});

/*
function loadSchedule()
{
    if (
        $('#villager').val() != ""
        && $('#season').val() != ""
        && $('#day').val() != ""
    ) {
        $.post($postURL, {
            'villager': $('#villager').val(),
            'season': $('#season').val(),
            'day': $('#day').val()
        }, function(data) {
            showPossibilities(data);
        }, 'json');
    }
}
*/

function updateColours()
{
    if ($(this).val() == "") {
        $(this).parent().switchClass('has-success', 'has-error', 500);
    } else {
        $(this).parent().switchClass('has-error', 'has-success', 500);
    }
}

/*
function showPossibilities(data)
{
    $('#possibilities').each(function() {
        $(this).fadeTo(300, 0);
    });

    $('#possibilities').promise().done(function() {

        $(this).empty();

        var count = 0;
        for(possible of data.possibilities) {
            ++count;

            var schedule = data.schedules[possible.schedule];
            console.log(schedule)

            var schedulelist = '<ul class="list-group">';
            for (item of schedule) {
                schedulelist += '<li class="list-group-item">'+item.time + ': ' + item.location+'</li>';
            }
            schedulelist += '<ul>';

            $(this).append(
                '<div class="col-sm-6 col-md-4 col-lg-3 panel">' +
                '<div class="bulletinpanel">' +
                '<div class="panel-heading"><h4>' +
                possible.extra +
                '</h4></div>' +
                schedulelist +
                '</div>' +
                '</div>'
            );

            if (count % 2 == 0) {
                $(this).append('<div class="clearfix visible-sm-block"></div>')
            }
            if (count % 3 == 0) {
                $(this).append('<div class="clearfix visible-md-block"></div>')
            }
            if (count % 4 == 0) {
                $(this).append('<div class="clearfix visible-lg-block"></div>')
            }

        }

        $(this).each(function() {
            $(this).fadeTo(300, 1);
        });
    });


}

*/