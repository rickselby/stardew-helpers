# frozen_string_literal: true

module StardewLoader
  # A single step in a schedule
  class Step
    attr_reader :definition

    VALID_TIME = /^a?(?<time>\d+)$/

    def initialize(person, definition, previous_map: nil, replacement: false)
      @definition = definition.split
      @person = person
      @replacement = replacement
      @previous_map = previous_map
    end

    def map
      return @previous_map unless map?

      @definition[index(1)]
    end

    def name
      Locations.get @person, map, [x, y]
    end

    def arrival_time?
      @definition[0].starts_with? "a"
    end

    def time
      raise "No time for a replacement" if replacement?

      @definition[0].match(VALID_TIME)[:time]
    end

    def to_s
      @definition.join " "
    end

    def valid?
      replacement? || VALID_TIME.match?(@definition[0])
    end

    def x
      @definition[index(2)].to_i
    end

    def y
      @definition[index(3)].to_i
    end

    private

    def index(index, check_has_map: true)
      index -= 1 if replacement?
      index -= 1 if check_has_map && !map?
      index
    end

    def map?
      @definition[index(1, check_has_map: false)].to_i.zero?
    end

    def replacement?
      @replacement
    end
  end
end
