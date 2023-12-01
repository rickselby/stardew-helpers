class LoadDescriptions
  PATH = Rails.root.join "data", "locations.yaml"

  def load_location_descriptions
    locations.each do |person, maps|
      maps.each do |map, spots|
        spots.each do |spot, description|
          x, y = spot.split ' '
          location = Location.find_by(map:, x:, y:)
          if location.nil?
            p "location nil?! #{{person:, map:, x:, y:}.inspect}"
            next
          end

          p "description already set! #{location.description} => #{description}" if location.description
          location.update description:
        end
      end
    end
  end

  def locations
    @locations ||= File.file?(PATH) ? YAML.load_file(PATH) : {}
  end
end
