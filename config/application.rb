# frozen_string_literal: true

require_relative "boot"

# require "rails/all"
# Replaced with:

require "rails"

%w[
  action_controller/railtie
  active_job/railtie
  action_cable/engine
  rails/test_unit/railtie
].each do |railtie|
  require railtie
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StardewHelpers
  # Main application
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
