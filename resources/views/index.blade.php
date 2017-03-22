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

    <div class="row" id="possibilities"></div>

    <script type="text/javascript">
        var $postURL = "{{ route('getSchedule') }}";
    </script>

@endsection