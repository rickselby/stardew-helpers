# frozen_string_literal: true

class MissingData < ActiveRecord::Migration[7.1]
  def change
    add_column :schedules, :rain, :boolean, default: false, null: false
    add_column :schedule_locations, :time, :string
  end
end
