# frozen_string_literal: true

module Stardew
  # A single step in a schedule
  class Route
    attr_reader :definition

    VALID_TIME = /^a?\d+$/.freeze

    def initialize(definition, replacement: false)
      @definition = definition.split
      @replacement = replacement
    end

    def as_json(_options = {})
      { time: replacement? ? nil : time, map: map, x: x, y: y }
    end

    def map
      replacement? ? @definition[0] : @definition[1]
    end

    def replacement?
      @replacement
    end

    def time
      raise 'No time for a replacement' if replacement?
      @definition[0]
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end

    def to_s
      @definition.join ' '
    end

    def valid?
      replacement? || VALID_TIME.match?(@definition[0])
    end

    def x
      (replacement? ? @definition[1] : @definition[2]).to_i
    end

    def x_y
      [x, y].join ' '
    end

    def y
      (replacement? ? @definition[2] : @definition[3]).to_i
    end
  end
end
