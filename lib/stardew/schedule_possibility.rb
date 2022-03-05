# frozen_string_literal: true

module Stardew
  # A single schedule
  class SchedulePossibility
    attr_accessor :notes, :priority, :routes

    def initialize(routes, notes, priority:, rain: false)
      @notes = notes.dup
      @priority = priority.dup
      @rain = rain.dup
      @routes = routes.dup
    end

    def first_route_word?(test)
      @routes.first.definition[0] == test
    end

    def second_route_word
      @routes.first.definition[1]
    end

    def friendship_notes
      notes = "Not at #{@routes.first.definition[3]} hearts with #{@routes.first.definition[2]}"
      if @routes.first.definition.length == 6
        notes = "#{notes} or #{@routes.first.definition[5]} hearts with #{@routes.first.definition[4]}"
      end
      notes
    end

    def mail_alt_schedule
      @routes[1].definition[1]
    end

    def remove_routes(n)
      @routes.shift(n)
    end

    def skip_nots
      remove_routes(1) if first_route_word? 'NOT'
    end
  end
end
