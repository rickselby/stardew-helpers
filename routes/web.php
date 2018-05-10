<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', 'ScheduleController@mainPage');

Route::post('/schedule', 'ScheduleController@getSchedule')->name('getSchedule');
Route::get('/map/{name}', 'ScheduleController@fullMap')->name('getFullMap');
Route::get('/map-sizes/', 'ScheduleController@mapSizes')->name('mapSizes');
Route::get('/portrait/{name}', 'ScheduleController@portrait')->name('getPortrait');
