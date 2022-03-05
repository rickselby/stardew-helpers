# frozen_string_literal: true

module Stardew
  # Information about locations in the game
  class Locations
    PATH = './data/locations.yaml'

    # Build the locations.yaml file
    def self.build
      locations = self.locations
      Dir['data/schedules/*'].map { |f| File.basename(f, '.json') }.sort.each do |person|
        person_locations = locations.key?(person) ? locations[person] : {}
        JSON.parse(File.read("data/schedules/#{person}.json")).each do |name, definition|
          Schedule.new(name, definition).routes.each do |r|
            next unless r.valid?

            person_locations[r.map] = {} unless person_locations.key? r.map
            person_locations[r.map][r.x_y] = '' unless person_locations[r.map].key? r.x_y
          end
        end
        person_locations.transform_values! { |v| v.sort_by { |k, _| k.split(' ').first.to_i }.to_h }
        locations[person] = person_locations.sort_by { |k, _| k }.to_h
      end
      File.write PATH, locations.to_yaml
    end

    def self.locations
      YAML::load_file PATH
    end
  end
end
