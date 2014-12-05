class Event < ActiveRecord::Base
  belongs_to :sensor
  belongs_to :species
  belongs_to :sex
  belongs_to :image
  belongs_to :precipitation
  belongs_to :temperature
  belongs_to :event_type

  def self.from_csv(file, sensor)
    csv = CSV.open(file, :col_sep => ';', :headers => true)
    csv.each do |dataset|
      next if dataset['event_type_name'].blank?
      record = self.record_from_hash dataset, sensor
      record.save
    end
  end

  def self.record_from_hash(hash, sensor)
    self.new :sensor => sensor do |record|
      record.timestamp  = DateTime.new *(hash['date'].split('.').reverse + hash['time'].split(':')).map(&:to_i)
      record.event_type = EventType.find_or_create_by(:name => hash['event_type_name'])
    end
  end

  before_validation do
    self.temperature   = Temperature.find_by(:date => self.timestamp.to_date)
    self.precipitation = Precipitation.find_by(:timestamp => (self.timestamp - 30.minutes)..(self.timestamp + 30.minutes))
  end
end
