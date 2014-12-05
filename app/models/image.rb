class Image < ActiveRecord::Base
  TIME_CORRECTION = 2697

  has_one :event

  scope :visible, lambda { where(:ignored => [nil, false]).where('timestamp IS NOT NULL').order('timestamp ASC') }

  attr_accessor :possible_events

  before_create do
    if self.filename
      Dir[Rails.root.join('public', 'images', '*', self.filename).to_s].each do |file|
        if EXIFR::JPEG.new(file).date_time.to_date == self.timestamp.to_date
          self.path = file.sub(Rails.root.join('public', 'images/').to_s, '')
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
    timestamp = DateTime.new *(hash['date'].split('.').reverse + hash['time'].split(':')).map(&:to_i)

    record = self.find_or_create_by :filename => hash['filename'], :timestamp => timestamp
    record.annotations = hash['annotations']

    if record.event
      sex     = Sex.find_or_create_by :name => hash['sex_name'].to_s.strip
      species = Species.find_or_create_by :name => hash['species_name'].to_s.strip
      record.event.update_attributes(:sex => sex, :species => species)
    end
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

  def ignore!
    self.update_attribute :ignored, true
  end

end
