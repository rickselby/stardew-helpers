# frozen_string_literal: true

module Stardew
  class GroupSchedules
    class << self
      def group(possibilities)
        groups = []
        possibilities.each do |possibility|
          if !groups.empty? && possibility.rain? && groups.last.rain?
            groups.last.possibilities << possibility
            next
          end

          groups.push SchedulePossibilityGroup.new(possibility)
        end

        groups
      end
    end
  end
end
