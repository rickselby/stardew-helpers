# frozen_string_literal: true

module Stardew
  # A single step in a schedule
  class Route
    attr_reader :definition

    def initialize(definition)
      @definition = definition.split
    end

    def as_json(_options = {})
      {
        time: @definition[0],
        map: @definition[1],
        x: @definition[2],
        y: @definition[3]
      }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
  end
end
