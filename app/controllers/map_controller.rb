class MapController < ApplicationController

  def map
    raise ActionController::RoutingError.new('Not Found') unless Stardew::Map.valid? params[:name]
    send_file Stardew::Map.new(params[:name]).file_path
  end

  def marker
    raise ActionController::RoutingError.new('Not Found') unless Stardew::Map.valid? params[:name]

    x = Integer(params[:x], 10)
    y = Integer(params[:y], 10)

    send_file Stardew::Map.new(params[:name]).with_marker(x, y)
  end
end
