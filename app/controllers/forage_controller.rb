class ForageController < ApplicationController
  def index
    if params[:data]
      data_params = ActionController::Parameters.new JSON.parse params[:data]
      @data = data_params.permit(:farmType, maps: [:map, spots: [:x, :y, :name]]).to_h.with_indifferent_access
      @data[:maps].select! { |m| Stardew::Map.valid? m[:map] }
    end
  end
end
