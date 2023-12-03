# frozen_string_literal: true

class CreatePersonSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :person_schedules do |t|
      t.references :person, null: false, foreign_key: true
      t.string :season
      t.integer :day
      t.integer :order
      t.references :schedule, null: false, foreign_key: true

      t.timestamps
    end
  end
end
