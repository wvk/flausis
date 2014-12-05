require 'solareventcalculator'
require 'csv'

class Precipitation < ActiveRecord::Base

  has_many :events

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
    self.select(:amount).uniq.order('amount ASC').pluck(:amount)
  end

  def self.to_csv(records)
    CSV.generate do |csv|
      csv << %w(timestamp precipitation_amount activity at_night)
      records.each do |record|
        csv << [record.timestamp, record.amount, record.activity, record.at_night?]
      end
    end
  end

  def activity
    self.events.count
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

end
