
<script type="text/javascript">
    var postURL = "{{ route('getSchedule') }}";
    var villagers = {!! $villagers->toJson() !!};
    var seasons = {!! $seasons->toJson() !!};
    var days = {!! $days->toJson() !!};
</script>

<div id="app">
    <possibilities></possibilities>
</div>

<div class="modal fade" tabindex="-1" role="dialog" id="mapModal" aria-labelledby="mapModal" >
    <div class="modal-dialog modal-variable" role="document">
        <div class="modal-content">
            <div class="modal-body">
                <img src="" />
            </div>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div><!-- /.modal -->

<div class="row center-block panel">
    <div class="wood-border">
        <h3>How to read the schedules</h3>
        <p>
            Read the panels from left to right. The first panel that applies should be the
            villager's schedule for the day. There many be alternatives for rain, for buildings
            being unavailable, or based on friendship that will override the regular schedule for
            a day.
        </p>
        <p>
            The times shown are when the villager will leave their previous location and head
            to the listed location.
        </p>
        </ul>
    </div>
</div>

<div class="row center-block panel">
    <div class="wood-border">
        <h3>About this app</h3>
        <p>
            This app reads the schedule files from the game, and parses them in the same way the game does, to decide
            which schedule a villager should take on a given day.
        </p>
        <p>
            I dug through the game source code and interpreted it as best I could, but there could still be some
            nuances that I missed.
        </p>
    </div>
</div>

