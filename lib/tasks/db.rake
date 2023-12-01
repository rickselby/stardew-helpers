namespace :db do
  desc "Populate the database"
  task populate: :environment do
    BuildDatabase.new.load_people
  end

  desc "Load existing descriptions"
  task load_descriptions: :environment do
    LoadDescriptions.new.load_location_descriptions
  end
end
