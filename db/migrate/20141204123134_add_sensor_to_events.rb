class AddSensorToEvents < ActiveRecord::Migration
  def change
    add_column :events, :sensor_id, :integer
  end
end
