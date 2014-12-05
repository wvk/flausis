class RenameAvgTemperature < ActiveRecord::Migration
  def change
    rename_column :temperatures, :avg, :ground
  end
end
