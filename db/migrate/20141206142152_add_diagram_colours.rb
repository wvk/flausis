class AddDiagramColours < ActiveRecord::Migration
  def change
    add_column :species, :diagram_colour, :string
    add_column :sexes, :diagram_colour, :string
    add_column :sensors, :diagram_colour, :string
    add_column :event_types, :diagram_colour, :string
  end
end
