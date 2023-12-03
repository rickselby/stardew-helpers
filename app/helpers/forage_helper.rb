# frozen_string_literal: true

# Helpers for the forage page
module ForageHelper
  def marker_style(map_name, spot)
    map_size = Stardew::Map.map_size map_name

    left = ((spot[:x].to_f / map_size[:x]) * 100)
    top = ((spot[:y].to_f / map_size[:y]) * 100)
    width = ((1.0 / map_size[:x]) * 100)

    "left: #{left}%; top: #{top}%; width: #{width}%"
  end

  def spot_name(spot)
    "(#{spot[:x]}, #{spot[:y]}): #{spot[:name]}"
  end
end
