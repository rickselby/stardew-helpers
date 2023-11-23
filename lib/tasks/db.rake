namespace :db do
  desc "Populate the database"
  task populate: :environment do
    BuildDatabase.new.load_people
  end
end
