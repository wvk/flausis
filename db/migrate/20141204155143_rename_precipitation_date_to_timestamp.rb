class RenamePrecipitationDateToTimestamp < ActiveRecord::Migration
  def change
    remove_column :precipitations, :date
    add_column :precipitations, :timestamp, :datetime
  end
end
