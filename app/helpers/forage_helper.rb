module ForageHelper

  # TODO - move into a class - maybe the map class?
  def map_sizes
    @map_sizes ||= Dir['data/maps/*.png'].to_h do |file_path|
      size = FastImage.size(file_path)
      [File.basename(file_path, '.png'), { x: size[0] / Stardew::Map::MAP_GRID, y: size[1] / Stardew::Map::MAP_GRID }]
    end
  end

  def get_map_size(map_name)
    map_sizes[map_name]
  end

  def marker_style(map_name, spot)
    map_size = get_map_size map_name

    left = ((spot[:x].to_f / map_size[:x]) * 100)
    top = ((spot[:y].to_f / map_size[:y]) * 100)
    width = ((1.0 / map_size[:x]) * 100)

    "left: #{left}%; top: #{top}%; width: #{width}%"
  end

  def spot_name(spot)
    "(#{spot[:x]}, #{spot[:y]}): #{spot[:name]}"
  end
end
