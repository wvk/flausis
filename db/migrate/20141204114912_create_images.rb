class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :filename
      t.date :date
      t.time :time
      t.string :annotations

      t.timestamps
    end
  end
end
