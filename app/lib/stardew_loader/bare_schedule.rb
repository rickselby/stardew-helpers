# frozen_string_literal: true

module StardewLoader
  # A single schedule line read from the json file
  class BareSchedule
    attr_reader :steps

    def initialize(person, name, definition)
      @name = name
      last = nil
      @steps = definition.split("/").map do |r|
        last = Step.new(person, r, replacement: replacement?, previous_map: last&.map)
      end
    end

    def replacement?
      @name.end_with? "_Replacement"
    end
  end
end
