# frozen_string_literal: true

module Stardew
  DAYS = (1..28).freeze
  SEASONS = %w[spring summer fall winter].freeze

  def self.each_day
    SEASONS.each do |season|
      DAYS.each do |day|
        yield season, day
      end
    end
  end
end
