require 'csv'

namespace :import do
  task :all => [:events, :images, :precipitations, :temperatures]

  task :events => :environment do
    Event.delete_all
    {'Export_LSunten' => 'LS unten', 'Export_LSmitte' => 'LS mitte', 'Export_LSoben' => 'LS oben'}.each_pair do |filename, sensor_name|
      Event.from_csv Rails.root.join('data', filename), Sensor.find_or_create_by(:name => sensor_name)
    end
  end

  task :images => :environment do
#     puts "deleting all image records"
#     Image.delete_all
    sensor     = Sensor.find_by(:name => 'LS unten')
    event_type = EventType.find_or_create_by(:name => 'Ausflug')

    filename = Rails.root.join('data', 'fledifotos.csv')
    puts "importing new image records from #{filename}"
    Image.from_csv filename, sensor, event_type
    puts "done"
  end

  task :precipitations => :environment do
    puts "deleting all precipitation records"
    Precipitation.delete_all

    filename = Rails.root.join('data', 'precipitation.hourly_sums.csv')
    puts "importing new precipitation records from #{filename}"
    Precipitation.from_csv filename

    puts "done"
  end

  task :temperatures => :environment do
    Temperature.from_csv Rails.root.join 'data', 'temperature.csv'
  end
end
