FlausiCalendar = Struct.new(:view, :date, :selection, :callback)

class FlausiCalendar
  HEADER = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
  START_DAY = :monday

  delegate :content_tag, to: :view

  def table
    content_tag :table, :class => 'calendar table table-bordered' do
      header + week_rows
    end
  end

  def header
    content_tag :tr do
      HEADER.map { |day| content_tag :th, day, :style => "width: #{100.0 / 7.0}%" }.join.html_safe
    end
  end

  def week_rows
    weeks.map do |week|
      content_tag :tr do
        week.map { |day| day_cell(day) }.join.html_safe
      end
    end.join.html_safe
  end

  def day_cell(day)
    content_tag :td, view.capture(day, &callback), :class => day_classes(day), 'data-date' => day
  end

  def day_classes(day)
    classes = []
    classes << 'today'     if day == Date.today
    classes << 'not-month' if day.month != date.month
    classes.empty? ? nil : classes.join(' ')
  end

  def weeks
    first = date.beginning_of_month.beginning_of_week(START_DAY)
    last  = date.end_of_month.end_of_week(START_DAY)
    (first..last).to_a.in_groups_of(7)
  end
end
