class CreateTemperatures < ActiveRecord::Migration
  def change
    create_table :temperatures do |t|
      t.date :date
      t.float :min
      t.float :max
      t.float :avg
      t.integer :station_id

      t.timestamps
    end
  end
end
