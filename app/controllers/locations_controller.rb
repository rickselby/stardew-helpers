# frozen_string_literal: true

class LocationsController < ApplicationController
  def index
    locations = Location.all
    @maps = locations.map(&:map).uniq.sort
    if @maps.include? params[:map]
      @map = params[:map]
      @locations = Location.includes(schedules: :people).where(map: @map)
    end

    @empty = locations.group_by(&:map).transform_values { |locs| locs.count { |l| l.description.blank? } }
  end

  def create
    Location.where(map: params[:map], x: params[:x], y: params[:y]).update(description: params[:description])
    head :ok
  end
end
