require 'mini_magick'

module Stardew
  class Map
    attr_reader :definition

    PATH = Rails.root.join "data", "maps"

    MAP_GRID = 16
    MAP_SIZE = 400

    class << self
      def map_with_marker(map, x, y)
        new(map).with_marker(x, y)
      end

      def marker
        @marker ||= MiniMagick::Image.open Rails.root.join "app", "assets", "images", "marker.png"
      end

      def valid?(map)
        valid_maps.include? map
      end

      private

      def valid_maps
        @valid_maps ||= Dir[PATH.join('*.png')].map { |f| File.basename f, '.png' }
      end
    end

    def initialize(map)
      @map = map
    end

    def with_marker(x, y)
      generate_marker_map x, y unless File.file? marker_map_path(x, y)
      marker_map_path x, y
    end

    private

    def add_marker(x, y)
      map_image.composite(self.class.marker) do |c|
        c.compose 'Over'
        c.geometry "+#{x * MAP_GRID}+#{y * MAP_GRID}"
      end
    end

    def crop_marker_map(image, x, y)
      image.crop "#{MAP_SIZE}x#{MAP_SIZE}+#{crop_offset(x)}+#{crop_offset(y)}"
    end

    def crop_offset(value)
      ((value + 0.5) * MAP_GRID)
    end

    # Add extra transparency to the map to ensure we end up with an image the right size with the marker in the middle
    def expand_marker_map(image)
      image.combine_options do |i|
        i.gravity 'center'
        i.background 'transparent'
        i.extent "#{image.width + MAP_SIZE}x#{image.height + MAP_SIZE}"
      end
    end

    def generate_marker_map(x, y)
      image = add_marker x, y
      expand_marker_map image
      crop_marker_map image, x, y
      image.write marker_map_path(x, y)
    end

    def map_image
      @map_image ||= MiniMagick::Image.open PATH.join "#{@map}.png"
    end

    def marker_map_path(x, y)
      PATH.join "generated", "#{@map}-#{x}-#{y}.png"
    end
  end
end
