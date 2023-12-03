# frozen_string_literal: true

class Schedule < ApplicationRecord
  has_many :person_schedules, dependent: :destroy
  has_many :schedule_locations, -> { order :order }, dependent: :destroy, inverse_of: :schedule

  has_many :people, through: :person_schedules

  def rain?
    rain
  end
end
