class AddIgnoredToImages < ActiveRecord::Migration
  def change
    add_column :images, :ignored, :boolean
    add_column :events, :ignored, :boolean
  end
end
