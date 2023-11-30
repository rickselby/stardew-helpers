class BuildDatabase
  def load_people
    Person.destroy_all
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
      schedule = Schedule.create(reference: possibility.notes)
      # TODO: load the locations into the schedule
      person.person_schedules.create(schedule:, season:, day:, order: possibility.priority)
    end
  end
end
