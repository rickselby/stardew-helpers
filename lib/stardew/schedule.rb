# frozen_string_literal: true

module Stardew
  # A single schedule
  class Schedule
    attr_reader :routes

    def initialize(name, routes)
      @name = name
      @routes = routes.split('/').map { |r| Route.new(r) }
    end
  end
end
