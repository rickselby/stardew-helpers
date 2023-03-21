class CalendarController < ApplicationController
  def index
    @people = Stardew::Schedules.valid_people
    @seasons = %w[spring summer fall winter]
    @days = 1..28
    # TODO: validation
    @person = params[:person]
    @season = params[:season]
    @day = params[:day]
  end
end
