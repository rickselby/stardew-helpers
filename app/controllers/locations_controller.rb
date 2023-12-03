# frozen_string_literal: true

class LocationsController < ApplicationController
  #     get '/locations' do
  #       @locations = Stardew::Locations.locations
  #       erb :locations
  #     end
  #
  #     post '/api/location' do
  #       Stardew::Locations.set params[:person], params[:map], params[:coords], params[:name]
  #       halt 200
  #     end

  def index
    locations = Stardew::Locations.locations
    @people = locations.keys
    if @people.include? params[:person]
      @person = params[:person]
      @locations = locations[@person]
    end

    @empty = locations.transform_values { |m| m.values.count { |l| l.values.any?(&:blank?) } }
  end

  def create
    Stardew::Locations.set params[:person], params[:map], params[:coords], params[:name]
    head :ok
  end
end
