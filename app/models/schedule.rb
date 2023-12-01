class Schedule < ApplicationRecord
  has_many :person_schedules, dependent: :destroy
  has_many :schedule_locations, -> { order order: :desc }, dependent: :destroy

  has_many :people, through: :person_schedules
end
