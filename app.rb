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

get '/' do
  erb :index
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
  Dir['data/portraits/*'].map { |f| File.basename(f, '.png') }
end

get '/portrait/:name' do
  halt 404 unless valid_portraits.include? params[:name]
  send_file File.expand_path("data/portraits/#{params[:name]}.png")
end

def valid_maps
  Dir['data/maps/*'].map { |f| File.basename(f, '.png') }
end

get '/map/:name/:x/:y' do
  halt 404 unless valid_maps.include? params[:name]
  x = Integer(params[:x], 10)
  y = Integer(params[:y], 10)

  send_file Stardew::Map.map_with_marker(params[:name], x, y)
end
