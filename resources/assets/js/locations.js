
$(document).ready(function() {
    $('#mapModal').on('show.bs.modal', function (event) {
        // Using .data() to get the data-map attribute seems to cache the information, so when the vue app changes
        // the links, we get the old images... Using .attr() doesn't cache anything, so we use that.
        var map = $(event.relatedTarget).attr('data-map');
        $(this).find('IMG').attr('src', 'map/' + map);
    });
});
