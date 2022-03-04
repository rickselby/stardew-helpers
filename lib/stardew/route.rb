# frozen_string_literal: true

module Stardew
  # A single step in a schedule
  class Route
    attr_reader :definition
    def initialize(definition)
      @definition = definition.split ' '
    end
  end
end
