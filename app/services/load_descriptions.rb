# frozen_string_literal: true

# Load existing description from a yaml file
class LoadDescriptions
  PATH = Rails.root.join "data/locations.yaml"

  def load_location_descriptions
    locations.each do |person, maps|
      maps.each do |map, spots|
        spots.each do |spot, description|
          load_description person, map, spot, description
        end
      end
    end
  end

  def locations
    @locations ||= File.file?(PATH) ? YAML.load_file(PATH) : {}
  end

  private

  def load_description(person, map, spot, description)
    x, y = spot.split
    location = Location.find_by(map:, x:, y:)
    if location.nil?
      Rails.logger.info { "location nil?! #{{ person:, map:, x:, y: }.inspect}" }
      return
    end

    Rails.logger.info { "description already set! #{location.description} => #{description}" } if location.description
    location.update! description:
  end
end
