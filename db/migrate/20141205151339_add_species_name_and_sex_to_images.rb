class AddSpeciesNameAndSexToImages < ActiveRecord::Migration
  def change
    add_column :images, :species_id, :integer
    add_column :images, :sex_id, :integer
  end
end
