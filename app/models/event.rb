class Event < ActiveRecord::Base
  belongs_to :sensor
  belongs_to :species
  belongs_to :sex
  belongs_to :image
  belongs_to :precipitation
  belongs_to :temperature
  belongs_to :event_type

  scope :ignored, lambda { where(:ignored => true) }
  scope :visible, lambda { where(:ignored => [nil, false]).order('timestamp ASC') }

  def self.from_csv(file, sensor)
    csv = CSV.open(file, :col_sep => ';', :headers => true)
    csv.each do |dataset|
      next if dataset['event_type_name'].blank?
#       $stderr.print '.'
#       $stderr.flush
      record = self.record_from_hash dataset, sensor
      record.save or raise "error! #{record.errors.inspect}"
    end
  end

  def self.record_from_hash(hash, sensor)
    timestamp  = DateTime.new *(hash['date'].split('.').reverse + hash['time'].split(':')).map(&:to_i)
    event_type = EventType.find_or_create_by(:name => hash['event_type_name'])

    self.find_or_initialize_by :sensor => sensor, :timestamp => timestamp, :event_type => event_type
  end

  before_validation do
    self.temperature   = Temperature.find_by(:date => self.timestamp.to_date)
    self.precipitation = Precipitation.find_by(:timestamp => (self.timestamp - 30.minutes)..(self.timestamp + 30.minutes))

    if self.image
      self.species ||= self.image.species
      self.sex     ||= self.image.sex
    end
  end

  def ignore!
    self.update_attribute :ignored, true
  end

end
