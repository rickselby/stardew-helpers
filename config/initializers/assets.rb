# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Don't let Propshaft serve the raw Sass sources; dartsass-rails compiles them
# into app/assets/builds instead.
Rails.application.config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")
