class CalendarController < ApplicationController
  def index
    @people = Stardew::Schedules.valid_people
    @seasons = %w[spring summer fall winter]
    @days = 1..28

    @person = params[:person]
    @season = params[:season]
    @day = params[:day].to_i

    @person = nil unless @people.include? @person
    unless @seasons.include?(@season) && @days.include?(@day)
      @season = nil
      @day = nil
    end

    unless [@person, @season, @day].any?(&:nil?)
      @groups = Stardew::Schedules.new(@person).group_schedules(@season, @day)
    end
  end
end
