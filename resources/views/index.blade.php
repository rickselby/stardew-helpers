@extends('outline')

@section('body')

    <div class="row center-block">
        <div class="col-xs-12 panel">
            <div class="interiorpanel">
                <h1 class="text-center">Stardew Valley Helpers</h1>
            </div>
        </div>
    </div>

    <div class="row center-block">
        <div class="col-sm-6 panel">
            <a href="#calendar" class="interiorpanel" data-toggle="tab">
                <h2>Villager Calendar</h2>
            </a>
        </div>
        <div class="col-sm-6 panel">
            <a href="#artifact" class="interiorpanel" data-toggle="tab">
                <h2>Artifact Finder</h2>
            </a>
        </div>
    </div>

    <div class="tab-content">
        <div role="tabpanel" class="tab-pane" id="calendar">
            @include('calendar')
        </div>
        <div role="tabpanel" class="tab-pane active" id="artifact">
            @include('artifact')
        </div>
    </div>


@endsection