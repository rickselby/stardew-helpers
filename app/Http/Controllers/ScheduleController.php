<?php

namespace App\Http\Controllers;

use App\Http\Requests\ScheduleRequest;
use App\Services\Schedules;

class ScheduleController extends Controller
{
    public function getSchedule(ScheduleRequest $request)
    {
        $schedule = new Schedules($request->input('villager'));
        return json_encode($schedule->getFor($request->input('season'), $request->input('day')));
    }
}
