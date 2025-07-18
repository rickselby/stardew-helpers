# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 2.7"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.6"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails", "~> 2.1"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 2.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", "~> 2.0", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18", require: false

# Use Sass to process CSS
gem "sassc-rails", "~> 2.1"

# Bootstrap
gem "bootstrap", "~> 5.3"

gem "fastimage", "~> 2.4"
gem "mini_magick", "~> 5.3"
gem "thruster", "~> 0.1.14"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "~> 1.11", platforms: %i[mri mingw x64_mingw]
  gem "rspec-rails", "~> 8.0"
  gem "rubocop-rickselby", "~> 0.59", require: false
end

group :development do
  gem "bundler-audit", "~> 0.9"

  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", "~> 4.2"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", "~> 3.40"
  gem "selenium-webdriver", "~> 4.10"
  gem "webdrivers", "~> 5.3"
end
