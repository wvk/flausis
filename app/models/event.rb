class Event < ActiveRecord::Base

  belongs_to :sensor
  belongs_to :species
  belongs_to :sex
  belongs_to :image
  belongs_to :precipitation
  belongs_to :temperature
  belongs_to :event_type

  scope :ignored, lambda { where(:ignored => true) }
  scope :visible, lambda { where(:ignored => [nil, false]).order('events.timestamp ASC') }

  def self.from_csv(file, sensor)
    csv = CSV.open(file, :col_sep => ';', :headers => true)
    csv.each do |dataset|
      next if dataset['event_type_name'].blank?
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
    time_range = (self.timestamp - 30.minutes)..(self.timestamp + 30.minutes)
    self.temperature   = Temperature.find_by(:timestamp => time_range)
    self.precipitation = Precipitation.find_by(:timestamp => time_range)

    if self.image
      self.species ||= self.image.species
      self.sex     ||= self.image.sex
    end
  end

  def ignore!
    self.update_attribute :ignored, true
  end

  def to_html
    %Q(<img src="data:image/png;base64,#{Base64.encode64(Rails.root.join('app', 'assets', 'images', 'activity.png').read)}">).html_safe
  end

  def date
    self.timestamp.to_date
  end

end
