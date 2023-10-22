class ForageController < ApplicationController
  def index
    # TODO - sanitize this data!
    @data = JSON.parse(params[:data]).with_indifferent_access if params[:data]
  end
end
