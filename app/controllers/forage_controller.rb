class ForageController < ApplicationController
  def index
    @data = JSON.parse(params[:data]) if params[:data]
  end
end
