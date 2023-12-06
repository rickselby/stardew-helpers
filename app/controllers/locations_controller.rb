# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action :load_maps

  def index
    return unless @maps.include? params[:map]

    @map = params[:map]
    @locations_to_show = Location.includes(schedules: :people).where(map: @map)
  end

  def create
    Location.where(map: params[:map], x: params[:x], y: params[:y]).update(description: params[:description])
    head :ok
  end

  private

  def load_maps
    @maps = locations.map(&:map).uniq.sort
    @empty = locations.group_by(&:map).transform_values { |locs| locs.count { |l| l.description.blank? } }
  end

  def locations
    @locations ||= Location.all
  end
end
