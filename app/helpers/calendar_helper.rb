module CalendarHelper
  def calendar_marker_position(day)
    row, day_of_week = coords_for day
    "left: #{day_of_week + 7}px; top: #{row + 37}px;"
  end

  def day_link_position(day)
    row, day_of_week = coords_for day
    [
      "position: absolute",
      "left: #{day_of_week + 9}px",
      "top: #{row + 39}px",
      "width: 32px",
      "height: 32px",
      "background-color: transparent"
    ].join ";"
  end

  def coords_for(day)
    (day.to_i - 1).divmod(7).map { |e| e * 32 }
  end
end
