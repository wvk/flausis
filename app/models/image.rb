class Image < ActiveRecord::Base
  TIME_CORRECTION = 2697

  has_one :event

  belongs_to :species
  belongs_to :sex
  belongs_to :temperature
  belongs_to :precipitation

  scope :visible, lambda { where(:ignored => [nil, false]).where('images.timestamp IS NOT NULL').order('images.timestamp ASC') }

  attr_accessor :possible_events

  before_save do
    unless self.filename.strip.blank?
      Dir[Rails.root.join('public', 'images', '*', self.filename).to_s].each do |file|
        image_timestamp = EXIFR::JPEG.new(file).date_time
        if image_timestamp.to_date == self.timestamp.to_date
          self.path = file.sub(Rails.root.join('public', 'images/').to_s, '')
#         else
#           puts "Timestamp of #{file}: #{image_timestamp} -- should be #{self.timestamp.to_date}"
        end
      end
    end
  end

  def self.from_csv(file, sensor, event_type)
    csv = CSV.open(file, :col_sep => ',', :headers => true)
    csv.each do |dataset|
      self.transaction do
        record = self.record_from_hash dataset, sensor, event_type
        record.try :save
      end
    end
  end

  def self.record_from_hash(hash, sensor, event_type)
    timestamp = Time.parse hash['timestamp']

    record = self.find_or_create_by :filename => hash['filename'], :timestamp => timestamp
    record.annotations = hash['annotations']

    sex           = Sex.find_or_create_by :name => hash['sex_name'].to_s.strip
    species       = Species.find_or_create_by :name => hash['species_name'].to_s.strip
    precipitation = Precipitation.find_by :timestamp => (timestamp - 30.minutes) .. (timestamp + 30.minutes)
    temperature   = Temperature.find_or_create_by :date => timestamp.to_date

#     if record.event
#       record.event.update_attributes(:sex => sex, :species => species)
#     else
      record.species       = species
      record.sex           = sex
      record.precipitation = precipitation
      record.temperature   = temperature
#     end
    record
  end

  def thumbnail_path
    if self.path.present?
      self.path.sub(/\.jpg/i, '-thm.jpg').sub('images/', '')
    end
  end

  def normalized_timestamp
    self.timestamp - TIME_CORRECTION.seconds
  end

  def date
    self.timestamp.to_date
  end

  def to_html
    %Q(<img src="#{self.thumbnail_path}" style="max-height: 24px">).html_safe
  end

  def ignore!
    self.update_attribute :ignored, true
  end

end
