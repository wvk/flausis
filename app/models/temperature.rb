class Temperature < ActiveRecord::Base

  has_many :events

  def self.from_csv(file)
    csv = CSV.open(file, :col_sep => ',', :headers => true)
    csv.each do |dataset|
      record = self.record_from_hash dataset
      if record.save
        Event.where(%q{date(timestamp) = ?}, record.date).each do |event|
          event.update_attribute :temperature, record
        end
      end
    end
  end

  def self.record_from_hash(hash)
    record = self.find_or_initialize_by :date => Date.parse(hash['Date'])

    record.attributes = {:min => hash['air temperature minimum'], :max => hash['air temperature maximum'], :ground => hash['air temperature at the ground']}
    record
  end

  def to_s
    "#{self.min}°C/#{self.max}°C"
  end

end
