class AddPrecipitationsToImages < ActiveRecord::Migration
  def change
    add_column :images, :precipitation_id, :integer
    add_column :images, :temperature_id, :integer

    Image.reset_column_information

    Image.all.each do |image|
      image.update_attributes \
          :temperature   => Temperature.find_by(:date => image.timestamp.to_date),
          :precipitation => Precipitation.find_by(:timestamp => (image.timestamp - 30.minutes) .. (image.timestamp + 30.minutes))
    end
  end
end
