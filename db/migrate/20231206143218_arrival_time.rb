# frozen_string_literal: true

class ArrivalTime < ActiveRecord::Migration[7.1]
  def change
    add_column :schedule_locations, :arrival_time, :boolean, default: false, null: false
  end
end
