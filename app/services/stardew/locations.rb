# frozen_string_literal: true

require 'yaml'

module Stardew
  # Information about locations in the game
  class Locations
    PATH = Rails.root.join "data", "locations.yaml"

    class << self
      # Build the locations.yaml file
      def build
        Stardew::Schedules.each_person do |person|
          locations[person] = sort_locations locations_from_schedule(person).merge(locations[person])
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

      def locations_from_schedule(person)
        target = Hash.new { |hash, key| hash[key] = {} }
        each_location_for(person) do |r|
          next unless r.valid?

          target[r.map][r.x_y] = ''
        end
        target
      end

      def each_location_for(person, &)
        JSON.parse(File.read(Stardew::Schedules.file_path_for(person))).each do |name, definition|
          BareSchedule.new(person, name, definition).steps.each(&)
        end
      end

      def sort_locations(list)
        list.transform_values { |v| v.sort { |a, b| sort_coords(a, b) }.to_h }.sort_by { |k, _| k }.to_h
      end

      def sort_coords(first, second)
        first = first[0].split.map(&:to_i)
        second = second[0].split.map(&:to_i)
        return first[1] <=> second[1] if first[0] == second[0]

        first[0] <=> second[0]
      end

      def write
        File.write PATH, locations.to_yaml
      end
    end
  end
end
