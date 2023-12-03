# frozen_string_literal: true

class CreateSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :schedules do |t|
      t.string :reference

      t.timestamps
    end
  end
end
