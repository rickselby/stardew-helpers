class VillagerController < ApplicationController
  def show
    name = params[:id]
    raise ActionController::RoutingError.new('Not Found') unless valid_portraits.include? name
    send_file File.expand_path("data/portraits/#{name}.png"), disposition: :inline
  end

  private

  def valid_portraits
    Dir['data/portraits/*.png'].map { |f| File.basename(f, '.png') }
  end
end
