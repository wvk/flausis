require 'solareventcalculator'
require 'csv'

class Precipitation < ActiveRecord::Base
  has_many :events
  has_many :sensors,
      :through => :events
  has_many :event_types,
      :through => :events

  has_many :images
  has_many :species,
      :through => :images
  has_many :sexes,
      :through => :images

  def self.from_csv(file)
    csv = CSV.open(file, :col_sep => ',', :headers => true)
    csv.each do |dataset|
      self.transaction do
        $stderr.print '.'
        $stderr.flush
        record = self.record_from_hash dataset
        if record
          record.save
          events = Event.where(:timestamp => (record.timestamp - 30.minutes)..(record.timestamp + 30.minutes))
          events.each do |event|
            event.update_attribute :precipitation, record
          end
        end
      end
    end
  end

  def self.record_from_hash(hash)
    timestamp = DateTime.parse(hash['Date'])
    self.new :timestamp => timestamp, :amount => hash['precipitation'].to_f
  end

  def self.amounts
    self.select(:amount).uniq.order('amount ASC').pluck(:amount).map{|s| '%.1f mm' % s }
  end

  def self.to_csv(records, options = {})
    headers = %w(timestamp precipitation_amount temperature at_night)
    species = []

    if options[:species_ids]
      species = Species.where(:id => options[:species_ids]).to_a
      headers += species.map(&:name)
    end

    CSV.generate do |csv|
      csv << headers
      records.each do |record|
        fields = [record.timestamp, record.amount, record.temperature.value, record.at_night?]

        fields += species.map{|s| record.species.where(:id => s.id).count }

        csv << fields
      end
    end
  end

  def sunrise
    @sun_calculator ||= SolarEventCalculator.new(self.timestamp.to_date, 51.288467, 7.290469)
    @sun_calculator.compute_utc_civil_sunrise
  end

  def sunset
    @sun_calculator ||= SolarEventCalculator.new(self.timestamp.to_date, 51.288467, 7.290469)
    @sun_calculator.compute_utc_civil_sunset
  end

  def at_night?
    self.timestamp < self.sunrise or self.timestamp > self.sunset
  end

  def to_s
    '%.1f' % self.amount
  end

  def temperature
    Temperature.find_by(:timestamp => self.timestamp)
  end

end
