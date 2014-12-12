class Temperature < ActiveRecord::Base

  has_many :events

  def self.from_csv(file)
    csv = CSV.open(file, :col_sep => ',', :headers => true)
    csv.each do |dataset|
      record = self.record_from_hash dataset
      if record.save
        Event.where(:timestamp => (record.timestamp - 30.minutes) .. (record.timestamp + 30.minutes)).each do |event|
          event.update_attribute :temperature, record
        end
      end
    end
  end

  def self.record_from_hash(hash)
    record = self.find_or_initialize_by :timestamp => Time.parse(hash['Date'])

    record.value = hash['air temperature']
    record
  end

  def to_s
    "#{self.value}°C"
  end

end
