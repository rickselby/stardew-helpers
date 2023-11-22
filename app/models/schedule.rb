class Schedule < ApplicationRecord
  has_many :person_schedules
  has_many :schedule_locations, -> { order order: :desc }

  has_many :people, through: :person_schedules
end
