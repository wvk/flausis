class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :species_id
      t.integer :sex_id
      t.integer :precipitation_id
      t.integer :temperature_id
      t.integer :event_type_id
      t.integer :image_id

      t.timestamps
    end
  end
end
