# frozen_string_literal: true

class Location < ApplicationRecord
  has_many :schedule_locations, dependent: :destroy
  has_many :schedules, through: :schedule_locations

  def coords
    "#{x}, #{y}"
  end

  def people
    schedules.map(&:people).flatten.uniq.sort_by(&:name)
  end
end
