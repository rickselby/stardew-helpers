# frozen_string_literal: true

class ScheduleLocation < ApplicationRecord
  belongs_to :schedule
  belongs_to :location
end
