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
            next unless Stardew::Schedules::VALID_TIME.match? r.definition[0]

            person_locations[r.definition[1]] = {} unless person_locations.key? r.definition[1]
            x_y_key = [r.definition[2], r.definition[3]].join ' '
            person_locations[r.definition[1]][x_y_key] = '' unless person_locations[r.definition[1]].key? x_y_key
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
