class BuildDatabase
  def initialize
    @locations = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
    Location.all.each do |l|
      @locations[l.map][l.x][l.y] = l
    end
  end

  def load_people
    [Location, Schedule, Person].each { |m| m.destroy_all }
    Stardew::People.each do |person_name|
      person = Person.create name: person_name
      load_schedules person
    end
  end

  def load_schedules(person)
    Stardew::SEASONS.each do |season|
      Stardew::DAYS.each do |day|
        load_schedule person, season, day
      end
    end
  end

  def load_schedule(person, season, day)
    Stardew::Schedules.new(person.name).schedule(season, day).each do |possibility|
      # TODO later: deduplicate the schedules
      schedule = Schedule.create(reference: possibility.notes, rain: possibility.rain?)
      load_locations schedule, possibility.steps
      person.person_schedules.create(schedule:, season:, day:, order: possibility.priority)
    end
  end

  def load_locations(schedule, steps)
    steps.each_with_index do |step, order|
      location = load_location step.map, step.x, step.y
      schedule.schedule_locations.create(location:, order: order + 1, time: step.time)
    end
  end

  def load_location(map, x, y)
    location = @locations.dig(map, x, y)
    return location if location.is_a? Location

    Location.create(map:, x:, y:)
            .tap { |l| @locations[map][x][y] = l }
  end
end
