class BuildDatabase
  def load_people
    Person.destroy_all
    Stardew::People.each do |person_name|
      Person.create name: person_name
      load_schedules person_name
    end
  end

  def load_schedules(person_name)
    Stardew::SEASONS.each do |season|
      Stardew::DAYS.each do |day|
        load_schedule person_name, season, day
      end
    end
  end

  def load_schedule(person_name, season, day)
    possibilities = Stardew::Schedules.new(person_name).schedule(season, day)
  end
end
