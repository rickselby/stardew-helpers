# frozen_string_literal: true

class CalendarController < ApplicationController
  before_action :load_data

  def index
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

  private

  def load_data
    @people = Person.order(:name)
    @seasons = Stardew::SEASONS
    @days = Stardew::DAYS
  end
end
