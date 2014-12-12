class ChangePrecisionOfTemperature < ActiveRecord::Migration
  def change
    remove_column :temperatures, :min, :float
    remove_column :temperatures, :max, :float
    remove_column :temperatures, :date, :date
    remove_column :temperatures, :ground, :float
    add_column :temperatures, :value, :float
    add_column :temperatures, :timestamp, :datetime
  end
end
