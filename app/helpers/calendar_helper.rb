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

  def schedule_panel_classes(group)
    extra = group.two_possibilities? ? %w[col-md-12 col-lg-8 col-xl-6] : %w[col-md-6 col-lg-4 col-xl-3]
    (%w[col-12] + extra).join " "
  end

  def schedule_classes(group)
    return "" unless group.two_possibilities?

    %w[col-6 two-rains].join " "
  end

  def format_time(time)
    time.rjust(4, '0').chars.each_slice(2).map(&:join).join(":")
  end

  def path_for_route(route)
    [route.map, route.x, route.y].join '/'
  end
end
