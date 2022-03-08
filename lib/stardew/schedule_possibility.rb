# frozen_string_literal: true

module Stardew
  # A single schedule
  class SchedulePossibility
    attr_accessor :name, :notes, :priority, :routes

    def initialize(name, routes, notes, priority:, rain: false)
      @name = name.dup
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

    def remove_routes(amount)
      @routes.shift(amount)
    end

    def skip_nots
      remove_routes(1) if first_route_word? 'NOT'
    end

    def as_json(_options = {})
      {
        notes: @notes,
        rain: @rain,
        routes: @routes.map(&:as_json)
      }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
  end
end
