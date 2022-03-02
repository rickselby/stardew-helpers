# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

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
  system 'ruby app.rb -p 8080'
end
