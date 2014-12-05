class CreatePrecipitations < ActiveRecord::Migration
  def change
    create_table :precipitations do |t|
      t.date :date
      t.float :amount
      t.integer :station_id

      t.timestamps
    end
  end
end
