# frozen_string_literal: true

class PersonSchedule < ApplicationRecord
  belongs_to :person
  belongs_to :schedule
end
