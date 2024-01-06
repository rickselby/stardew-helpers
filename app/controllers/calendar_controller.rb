# frozen_string_literal: true

class CalendarController < ApplicationController
  before_action :load_data, :load_params

  def index
    load_groups unless [@person, @season, @day].any?(&:nil?)
  end

  private

  def load_data
    @people = Person.order :name
    @seasons = Stardew::SEASONS
    @days = Stardew::DAYS
  end

  def load_params
    @person = Person.find_by name: params[:person]
    return unless @seasons.include?(params[:season]) && @days.include?(params[:day].to_i)

    @season = params[:season]
    @day = params[:day].to_i
  end

  def load_groups
    schedules = @person.person_schedules.where(season: @season, day: @day).order(:order)
    schedules = schedules.map(&:schedule)
    @groups = Stardew::ScheduleGroup.group schedules
  end
end
