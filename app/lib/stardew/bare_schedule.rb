# frozen_string_literal: true

class Stardew
  # A single schedule line read from the json file
  class BareSchedule
    attr_reader :steps

    def initialize(person, name, definition)
      @name = name
      @steps = definition.split("/").map { |r| Step.new(person, r, replacement: replacement?) }
    end

    def replacement?
      @name.end_with? "_Replacement"
    end
  end
end
