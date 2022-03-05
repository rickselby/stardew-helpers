# frozen_string_literal: true

module Stardew
  # A single step in a schedule
  class Map
    attr_reader :definition

    MAP_GRID = 16
    MAP_SIZE = 400

    def self.map_with_marker(map, x, y)
      self.new(map).with_marker(x, y)
    end

    def initialize(map)
      @map = map
    end

    def with_marker(x, y)
      result = map_image.composite(self.class.marker) do |c|
        c.compose 'Over'
        c.geometry "+#{x * MAP_GRID}+#{y * MAP_GRID}"
      end
      result.crop "#{MAP_SIZE}x#{MAP_SIZE}+#{get_crop_offset(x)}+#{get_crop_offset(y)}"
      result.path
    end

    private

    def get_crop_offset(v)
      ((v + 0.5) * MAP_GRID) - (MAP_SIZE / 2)
    end

    def map_image
      @map_image ||= MiniMagick::Image.open("./data/maps/#{@map}.png")
    end

    def self.marker
      @marker ||= MiniMagick::Image.open('./images/marker.png')
    end
  end
end
