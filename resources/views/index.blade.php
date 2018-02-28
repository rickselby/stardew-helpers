@extends('outline')

@section('body')

    <div class="row center-block">
        <div class="col-md-12 col-sm-12 panel">
            <div class="interiorpanel">
                <div class="row">
                    <h1 class="text-center">Stardew Valley Calendar</h1>
                </div>
                <div class="row hidden-xs">
                    <div class="col-xs-12">
                        <h3 class="text-center">
                            Find where the villagers are hiding
                        </h3>
                    </div>
                </div>
            </div>
        </div>
    </div>

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
                    <img />
                </div>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

    <div class="row center-block panel">
        <div class="interiorpanel">
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
        <div class="interiorpanel">
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

    <div class="row center-block panel text-center">
        <div class="interiorpanel">
            <p class="text-muted">
                Huge thanks to <a href="http://upload.farm">upload.farm</a> for allowing me to use their bootstrap theme
                <br />
                All Stardew Valley assets copyright <a href="http://twitter.com/concernedape">Concerned Ape</a>
            </p>
        </div>
    </div>


@endsection