class MapController < ApplicationController
  def show
    raise ActionController::RoutingError.new('Not Found') unless Stardew::Map.valid? params[:name]

    x = Integer(params[:x], 10)
    y = Integer(params[:y], 10)

    send_file Stardew::Map.map_with_marker(params[:name], x, y)
  end
end
