module CalendarHelper
  def get_coords(day)
    row, day_of_week = (day - 1).divmod 7
    [
      (day_of_week * 32) + 9,
      (row * 32) + 39,
      (day_of_week * 32) + 41,
      (row * 32) + 71,
    ].join ','
  end
end
