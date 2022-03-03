# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require

configure do
  set :erb, escape_html: true
  set :show_exceptions, :after_handler if development?
  disable :dump_errors unless development?
end

before do
  cache_control :no_cache
end

# Routes from laravel
# Route::get('/', 'ScheduleController@mainPage');
# Route::post('/schedule', 'ScheduleController@getSchedule')->name('getSchedule');
# Route::get('/map/{name}', 'ScheduleController@fullMap')->name('getFullMap');
# Route::get('/map/{name}/{x}/{y}', 'ScheduleController@map')->name('getMap');
# Route::get('/map-sizes/', 'ScheduleController@mapSizes')->name('mapSizes');
# Route::get('/portrait/{name}', 'ScheduleController@portrait')->name('getPortrait');

get '/' do
  erb :index
end

