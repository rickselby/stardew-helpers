<?php

namespace App\Http\Controllers;

use App\Http\Requests\ScheduleRequest;
use App\Services\Locations;
use App\Services\Schedules;
use App\Services\Seasons;
use App\Services\Villagers;

class ScheduleController extends Controller
{
    public function mainPage(Villagers $villagers, Seasons $seasons)
    {
        return view('index')
            ->with('villagers', $villagers->getList()->sort())
            ->with('seasons', $seasons->getList());
    }

    public function getSchedule(ScheduleRequest $request, Locations $locations)
    {
        $schedules = new Schedules($request->input('villager'));
        $schedule = $schedules->getFor($request->input('season'), $request->input('day'));
        $locations->parseLocations($schedule['schedules']);

        return json_encode($schedule);
    }
}