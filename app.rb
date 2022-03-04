# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require

Dir['./lib/**/*.rb'].sort.each { |file| require file }

configure do
  set :erb, escape_html: true
  set :show_exceptions, :after_handler if development?
  disable :dump_errors unless development?
end

before do
  cache_control :no_cache
end

before '/api/*' do
  content_type :json
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

get '/api/people' do
  Dir['data/schedules/*'].map { |f| File.basename(f, '.json') }.sort.to_json
end

post '/api/schedules' do
  Dir['data/schedules/*'].map { |f| File.basename(f, '.json') }.sort.to_json
end

def valid_portraits
  Dir['data/portraits/*'].map { |f| File.basename(f, '.png') }
end

get '/portrait/:name' do
  halt 404 unless valid_portraits.include? params[:name]
  send_file File.expand_path("data/portraits/#{params[:name]}.png")
end
