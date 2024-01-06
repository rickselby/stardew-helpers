# frozen_string_literal: true

module Stardew
  # Read portrait files
  module Portraits
    module_function

    PATH = Rails.root.join "data/portraits"

    def path(name)
      PATH.join "#{name}.png"
    end

    def valid?(name)
      valid_portraits.include? name
    end

    def valid_portraits
      @valid_portraits ||= Dir[PATH.join "*.png"].map { |f| File.basename f, ".png" }
    end
  end
end
