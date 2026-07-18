# frozen_string_literal: true

# Sass entry points to compile into app/assets/builds.
# Key: source file in app/assets/stylesheets. Value: compiled output filename.
Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css",
}
