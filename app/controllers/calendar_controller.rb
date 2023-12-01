class CalendarController < ApplicationController
  def index
    @people = Person.order(:name)
    @seasons = Stardew::SEASONS
    @days = Stardew::DAYS

    @person = Person.find_by(name: params[:person])
    if @seasons.include?(params[:season]) && @days.include?(params[:day].to_i)
      @season = params[:season]
      @day = params[:day].to_i
    end

    unless [@person, @season, @day].any?(&:nil?)
      schedules = @person.person_schedules.where(season: @season, day: @day).order(:order)
      schedules = schedules.map(&:schedule)
      @groups = Stardew::ScheduleGroup.group schedules
    end
  end
end
