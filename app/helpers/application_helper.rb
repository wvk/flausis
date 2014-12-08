require 'calendar'

module ApplicationHelper
  def t(*args)
    super(*args).html_safe
  end

  def calendar(date = Date.today, selection, &block)
    FlausiCalendar.new(self, date, selection, block).table
  end
end
