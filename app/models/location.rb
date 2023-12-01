class Location < ApplicationRecord
  has_many :schedule_locations, dependent: :destroy
  has_many :schedules, through: :schedule_locations

  def people
    schedules.map(&:people).uniq
  end
end
