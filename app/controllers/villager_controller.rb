# frozen_string_literal: true

class VillagerController < ApplicationController
  def show
    name = params[:id]
    raise ActionController::RoutingError, "Not Found" unless Stardew::Portraits.valid? name

    send_file Stardew::Portraits.path(name), disposition: :inline
  end
end
