# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.2"

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 2.9"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 7.2"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails", "~> 2.2"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "~> 2.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", "~> 2.0", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.22", require: false

# Use Sass to process CSS
gem "sassc-rails", "~> 2.1"

# Bootstrap
gem "bootstrap", "~> 5.3"

gem "fastimage", "~> 2.4"
gem "mini_magick", "~> 5.3"
gem "thruster", "~> 0.1.18"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "~> 1.11", platforms: %i[mri windows]
  gem "rspec-rails", "~> 8.0"
  gem "rubocop-rickselby", "~> 0.68", require: false
end

group :development do
  gem "bundler-audit", "~> 0.9"
  gem "lefthook", "~> 2.1"
  gem "web-console", "~> 4.2"
end

group :test do
  gem "capybara", "~> 3.40"
  gem "selenium-webdriver", "~> 4.10"
  gem "webdrivers", "~> 5.3"
end
