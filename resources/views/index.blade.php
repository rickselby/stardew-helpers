@extends('outline')

@section('body')
    <div class="jumbotron">
        <h1>
            Stardew Valley Calendar
        </h1>
        <p>Find out what the villagers are up to on a particular day</p>
    </div>

    <div class="row">
        <div class="col-sm-4 has-error">
            <select id="villager" name="villager" class="form-control">
                <option value="">Select a villager...</option>
                @foreach($villagers AS $villager)
                    <option value="{{ $villager }}">{{ $villager }}</option>
                @endforeach
            </select>
        </div>
        <div class="col-sm-4 has-error">
            <select id="season" name="season" class="form-control">
                <option value="">Select a season...</option>
                @foreach($seasons AS $season)
                    <option value="{{ $season }}">{{ \Illuminate\Support\Str::ucfirst($season) }}</option>
                @endforeach
            </select>
        </div>
        <div class="col-sm-4 has-error">
            <select id="day" name="day" class="form-control">
                <option value="">Select a day...</option>
                @for($day = 1; $day <= 28; $day++)
                    <option value="{{ $day }}">{{ $day }}</option>
                @endfor
            </select>
        </div>
    </div>

    <div class="col-sm-12" style="height:30px;">&nbsp;</div>

    <div class="row" id="possibilities" style="border: 1px solid white;"></div>

    <div class="panel panel-default">
        <div class="panel-heading">
            How to read the information
        </div>
        <ul class="list-group">
            <li class="list-group-item">
                Read the panels from left to right. The first panel that applies should be the
                villager's schedule for the day. There many be alternatives for rain, for buildings
                being unavailable, or based on friendship that will override the regular schedule for
                a day.
            </li>
            <li class="list-group-item">
                If there are two panels for rain, there is an equal, random chance of either being picked.
            </li>
            <li class="list-group-item">
                The times shown are when the villager will leave their previous location and head
                to the listed location.
            </li>
            <li class="list-group-item">
                If a villager has a location listed multiple times in a row, this normally means they're
                moving around in a room / house.
            </li>
        </ul>
    </div>

    <script type="text/javascript">
        var $postURL = "{{ route('getSchedule') }}";
    </script>

@endsection