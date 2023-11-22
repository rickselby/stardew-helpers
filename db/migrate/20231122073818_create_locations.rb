class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.string :map
      t.integer :x
      t.integer :y
      t.string :description

      t.timestamps
    end
  end
end
