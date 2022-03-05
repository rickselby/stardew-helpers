# frozen_string_literal: true

module Stardew
  # A single step in a schedule
  class Route
    attr_reader :definition

    VALID_TIME = /^a?\d+$/.freeze

    def initialize(definition)
      @definition = definition.split
    end

    def as_json(_options = {})
      { time: time, map: map, x: x, y: y }
    end

    def map
      @definition[1]
    end

    def time
      @definition[0]
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end

    def to_s
      @definition.join ' '
    end

    def valid?
      VALID_TIME.match? @definition[0]
    end

    def x
      @definition[2]
    end

    def x_y
      [x, y].join ' '
    end

    def y
      definition[3]
    end
  end
end
