<?php

namespace App\Http\Controllers;

use App\Http\Requests\ScheduleRequest;
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

    public function getSchedule(ScheduleRequest $request)
    {
        $schedule = new Schedules($request->input('villager'));
        return json_encode($schedule->getFor($request->input('season'), $request->input('day')));
    }
}
