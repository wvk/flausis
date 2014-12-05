class ChangeImageDateAndTimeToTimestamp < ActiveRecord::Migration
  def change
    add_column :images, :timestamp, :datetime
    remove_column :images, :date
    remove_column :images, :time
  end
end
