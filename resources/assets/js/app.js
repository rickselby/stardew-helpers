
/**
 * First we will load all of this project's JavaScript dependencies which
 * includes Vue and other libraries. It is a great starting point when
 * building robust, powerful web applications using Vue and Laravel.
 */

require('./bootstrap');

$( document ).ready(function() {

    $('select').change(updateColours);
    $('select').change(loadSchedule);

});

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

function updateColours()
{
    if ($(this).val() == "") {
        $(this).parent().switchClass('has-success', 'has-error', 500);
    } else {
        $(this).parent().switchClass('has-error', 'has-success', 500);
    }
}

function showPossibilities(data)
{
    $('#possibilities').empty();

    for(possible of data.possibilities) {

        var schedule = data.schedules[possible.schedule];
        console.log(schedule)

        var schedulelist = '<ul class="list-group">';
        for (item of schedule) {
            schedulelist += '<li class="list-group-item">'+item+'</li>';
        }
        schedulelist += '<ul>';

        $('#possibilities').append(
            '<div class="col-sm-3">' +
            '<div class="panel panel-default">' +
            '<div class="panel-heading">' +
            possible.extra +
            '</div>' +
            schedulelist +
            '</div>' +
            '</div>'
        );
    }

}