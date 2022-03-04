# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

Dir['./lib/**/*.rb'].sort.each { |file| require file }

Bundler.setup
Bundler.require(:development, :test)

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'bundler/audit/task'
Bundler::Audit::Task.new

desc 'Run audit check'
task :audit do
  system 'bundle exec bundler-audit check --update'
end

desc 'Bring up app'
task :up do
  system 'rerun --background --no-notify -- ruby app.rb -p 8080'
end

desc 'Check all schedules are parseable'
namespace :check do
  task :schedules do
    Dir['data/schedules/*'].map { |f| File.basename(f, '.json') }.sort.each do |person|
      schedules = Stardew::Schedules.new(person)
      %w[spring summer fall winter].each do |season|
        (1..28).each do |day|
          schedules.check season, day
        end
      end
    end
  end
end
