# frozen_string_literal: true

require 'yaml'

module Stardew
  # Information about locations in the game
  class Locations
    PATH = './data/locations.yaml'
    class << self
      # Build the locations.yaml file
      def build
        Stardew::Schedules.each_person do |person|
          person_locations = locations.key?(person) ? locations[person] : {}
          JSON.parse(File.read("data/schedules/#{person}.json")).each do |name, definition|
            Schedule.new(person, name, definition).routes.each do |r|
              next unless r.valid?

              person_locations[r.map] = {} unless person_locations.key? r.map
              person_locations[r.map][r.x_y] = '' unless person_locations[r.map].key? r.x_y
            end
          end
          person_locations.transform_values! { |v| v.sort_by { |k, _| k.split.first.to_i }.to_h }
          locations[person] = person_locations.sort_by { |k, _| k }.to_h
        end
        write
      end

      def get(person, map, coords)
        locations[person][map][coords.join ' ']
      end

      def locations
        @locations ||= File.file?(PATH) ? YAML.load_file(PATH) : {}
      end

      def set(person, map, coords, name)
        @locations[person][map][coords] = name
        write
      end

      private

      def write
        File.write PATH, locations.to_yaml
      end
    end
  end
end
