class EventType < ActiveRecord::Base
  has_many :events

  def to_s
    self.name
  end

  def self.[](val)
    self.find_by(:name => val)
  end
end
