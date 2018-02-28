
/**
 * We'll load jQuery and the Bootstrap jQuery plugin which provides support
 * for JavaScript based Bootstrap features such as modals and tabs. This
 * code may be modified to fit the specific needs of your application.
 */

window.$ = window.jQuery = require('jquery');

require("jquery-ui/ui/effect");

require('bootstrap-sass');

window.Vue = require('vue');

$.ajaxSetup({
    headers: {
        'X-CSRF-TOKEN': $('meta[name=csrf-token]').attr("content"),
    }
});

$(document).ready(function() {
    $('#mapModal').on('show.bs.modal', function (event) {
        // Using .data() seems to cache the information, so when the vue app changes the links, we get the old images
        // Using .attr() doesn't cache anything...?
        var map = $(event.relatedTarget).attr('data-map');
        $(this).find('IMG').attr('src', 'map/' + map);
    });
});
