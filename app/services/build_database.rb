class BuildDatabase
  def load_people
    Person.destroy_all
    Stardew::Schedules.valid_people.each { |person_name| Person.create name: person_name }
  end
end
