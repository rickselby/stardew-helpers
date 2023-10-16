module Stardew
  class SchedulePossibilityGroup
    attr_accessor :possibilities

    def initialize(possibility)
      @possibilities = [possibility]
    end

    def two_possibilities?
      @possibilities.length == 2
    end

    def notes
      @possibilities.first.notes
    end

    def rain?
      @possibilities.first.rain?
    end

    def to_partial_path
      'group'
    end
  end
end
