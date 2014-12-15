require 'csv'
Time.zone = 'Europe/Berlin'

class ObservationSession < ActiveRecord::Base

  has_many :images
  has_many :events
  has_many :precipitations
  has_many :temperatures

  after_save do
    Image.where(:timestamp => self.start_time..self.end_time)
  end

  after_save do
    Image.where(:timestamp => self.start_time .. self.end_time).each do |image|
      image.update_attribute :observation_session, self
    end
    Event.where(:timestamp => self.start_time .. self.end_time).each do |record|
      record.update_attribute :observation_session, self
    end
    Precipitation.where(:timestamp => self.start_time .. self.end_time).each do |record|
      record.update_attribute :observation_session, self
    end
    Temperature.where(:timestamp => self.start_time .. self.end_time).each do |record|
      record.update_attribute :observation_session, self
    end
  end

  def precipitation_amount
    self.precipitations.sum(:amount)
  end

  def min_temperature
    self.temperatures.minimum(:value)
  end

  def self.to_csv(records, options = {})
    headers = %w(start_time end_time precipitation_amount min_temperature at_night overall_activity)
    species = []

    if options[:species_ids]
      species = Species.where(:id => options[:species_ids]).to_a
      headers += species.map(&:name)
    end

    CSV.generate do |csv|
      csv << headers
      records.each do |record|
        fields = [record.start_time, record.end_time, record.precipitation_amount, record.min_temperature, record.at_night?, record.images.count]
        fields += species.map{|s| record.images.where(:species_id => s.id).count }

        csv << fields
      end
    end
  end
end
