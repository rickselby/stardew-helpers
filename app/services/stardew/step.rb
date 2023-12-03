# frozen_string_literal: true

module Stardew
  # A single step in a schedule
  class Step
    attr_reader :definition

    VALID_TIME = /^a?\d+$/

    def initialize(person, definition, replacement: false)
      @definition = definition.split
      @person = person
      @replacement = replacement
    end

    def map_path
      [map, x, y].join "/"
    end

    def map
      replacement? ? @definition[0] : @definition[1]
    end

    def name
      Locations.get @person, map, [x, y]
    end

    def replacement?
      @replacement
    end

    def time
      raise "No time for a replacement" if replacement?

      @definition[0]
    end

    def to_s
      @definition.join " "
    end

    def valid?
      replacement? || VALID_TIME.match?(@definition[0])
    end

    def x
      (replacement? ? @definition[1] : @definition[2]).to_i
    end

    def x_y
      [x, y].join " "
    end

    def y
      (replacement? ? @definition[2] : @definition[3]).to_i
    end
  end
end
