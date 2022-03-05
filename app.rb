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

def valid_schedule
  Dir['data/schedules/*'].map { |f| File.basename(f, '.json') }
end

get '/api/people' do
  valid_schedule.sort.to_json
end

post '/api/schedules' do
  halt 400 unless valid_schedule.include? params[:person]
  halt 400 unless %w[spring summer fall winter].include? params[:season]
  halt 400 unless (1..28).map(&:to_s).include? params[:day]

  schedule = Stardew::Schedules.new(params[:person])
  schedule.schedule(params[:season], params[:day]).to_json
end

def valid_portraits
  Dir['data/portraits/*'].map { |f| File.basename(f, '.png') }
end

get '/portrait/:name' do
  halt 404 unless valid_portraits.include? params[:name]
  send_file File.expand_path("data/portraits/#{params[:name]}.png")
end

def valid_maps
  Dir['data/maps/*'].map { |f| File.basename(f, '.png') }
end

MAP_GRID = 16
MAP_SIZE = 400

get '/map/:name/:x/:y' do
  halt 404 unless valid_maps.include? params[:name]
  x = Integer(params[:x], 10)
  y = Integer(params[:y], 10)

  map = MiniMagick::Image.open("./data/maps/#{params[:name]}.png")
  marker = MiniMagick::Image.open('./images/marker.png')
  result = map.composite(marker) do |c|
    c.compose 'Over'
    c.geometry "+#{x * MAP_GRID}+#{y * MAP_GRID}"
  end
  result.crop "#{MAP_SIZE}x#{MAP_SIZE}+#{get_crop_offset(x)}+#{get_crop_offset(y)}"

  send_file result.path
end

def get_crop_offset(v)
  ((v + 0.5) * MAP_GRID) - (MAP_SIZE / 2)
end
