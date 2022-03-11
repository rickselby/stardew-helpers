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

desc 'Bring up app'
task :up do
  system 'rerun --background --no-notify -- ruby app.rb -p 8080'
end

desc 'Build a list of locations'
task :build_locations do
  Stardew::Locations.build
end

desc 'Build all maps'
task :build_maps do
  Stardew::Schedules.each_person do |person|
    JSON.parse(File.read("data/schedules/#{person}.json")).each do |name, definition|
      Stardew::Schedule.new(person, name, definition).routes.each do |r|
        next unless r.valid?

        p r.to_json
        Stardew::Map.map_with_marker r.map, r.x, r.y
      rescue Errno::ENOENT
        # continue...
      end
    end
  end
end

namespace :check do
  desc 'Check all schedules are parseable'
  task :schedules do
    Stardew::Schedules.each_person do |person|
      schedules = Stardew::Schedules.new(person)
      Stardew.each_day do |season, day|
        schedules.check season, day
      end
    end
  end
end

def node_command(command, name: nil)
  flags = [
    '--rm',
    '-i',
    "-v #{Dir.pwd}:/app",
    '-w /app',
    '--env HOME=./.node',
    "--user #{Process.uid}:#{Process.gid}"
  ]
  flags.push "--name #{name}" unless name.nil?

  "docker run #{flags.join ' '} node:16-alpine #{command}"
end

namespace :npm do
  desc 'Run npm install'
  task :install do
    system node_command 'npm install'
  end

  desc 'Run npm update'
  task :update do
    system node_command 'npm update'
  end
end

desc 'Run webpack for dev'
task :webpack do
  system node_command 'npx webpack --config webpack.dev.js'
end

namespace :webpack do
  desc 'Run webpack watch'
  task :watch do
    system node_command 'npx webpack watch --config webpack.dev.js'
  end

  desc 'Run webpack production'
  task :prod do
    system node_command 'npx webpack --config webpack.prod.js'
  end
end
