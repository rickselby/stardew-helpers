class Person < ApplicationRecord
  has_many :person_schedules, -> { order order: :desc }
end
