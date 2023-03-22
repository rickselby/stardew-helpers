module CalendarHelper
  def get_coords(day)
    row, day_of_week = coords_for day
    [
      day_of_week + 9,
      row + 39,
      day_of_week + 41,
      row + 71,
    ].join ','
  end

  def calendar_marker_position(day)
    row, day_of_week = coords_for day
    left = 7 + day_of_week
    top = 37 + row
    "left: #{left}px; top: #{top}px;"
  end

  def coords_for(day)
    (day.to_i - 1).divmod(7).map { |e| e * 32 }
  end
end
