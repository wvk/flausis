class AddTimeToEvent < ActiveRecord::Migration
  def change
    add_column :events, :timestamp, :datetime
  end
end
