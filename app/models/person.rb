# frozen_string_literal: true

class Person < ApplicationRecord
  has_many :person_schedules, -> { order order: :desc }, dependent: :destroy, inverse_of: :person
end
