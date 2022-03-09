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

before '/api/*' do
  content_type :json
end

get '/' do
  erb :index
end

get '/api/map-sizes' do
  Dir['data/maps/*.png'].to_h do |file_path|
    size = FastImage.size(file_path)
    [File.basename(file_path, '.png'), { x: size[0] / Stardew::Map::MAP_GRID, y: size[1] / Stardew::Map::MAP_GRID }]
  end.to_json
end

get '/api/people' do
  Stardew::Schedules.valid_people.sort.to_json
end

post '/api/schedules' do
  halt 400 unless Stardew::Schedules.valid_people.include? params[:person]
  halt 400 unless Stardew::SEASONS.include? params[:season]
  halt 400 unless Stardew::DAYS.map(&:to_s).include? params[:day]

  schedule = Stardew::Schedules.new(params[:person])
  schedule.schedule(params[:season], params[:day]).to_json
end

def valid_portraits
  Dir['data/portraits/*.png'].map { |f| File.basename(f, '.png') }
end

get '/portrait/:name' do
  halt 404 unless valid_portraits.include? params[:name]
  send_file File.expand_path("data/portraits/#{params[:name]}.png")
end

def valid_maps
  Dir['data/maps/*.png'].map { |f| File.basename(f, '.png') }
end

get '/map/:name/:x/:y' do
  halt 404 unless valid_maps.include? params[:name]
  x = Integer(params[:x], 10)
  y = Integer(params[:y], 10)

  send_file Stardew::Map.map_with_marker(params[:name], x, y)
end

get '/map/:name' do
  halt 404 unless valid_maps.include? params[:name]
  send_file File.expand_path("data/maps/#{params[:name]}.png")
end

if development?
  get '/locations' do
    @locations = Stardew::Locations.locations
    erb :locations
  end

  post '/api/location' do
    Stardew::Locations.set params[:person], params[:map], params[:coords], params[:name]
    halt 200
  end
end
