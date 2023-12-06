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

    def map_path
      [map, x, y].join "/"
    end

    def map
      return @previous_map unless has_map?

      @definition[index(1)]
    end

    def index(i, check_has_map: true)
      i -= 1 if replacement?
      if check_has_map
        i -= 1 unless has_map?
      end
      i
    end

    def name
      Locations.get @person, map, [x, y]
    end

    def replacement?
      @replacement
    end

    def has_map?
      @definition[index(1, check_has_map: false)].to_i.zero?
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

    def x_y
      [x, y].join " "
    end

    def y
      @definition[index(3)].to_i
    end
  end
end
