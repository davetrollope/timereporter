class UIState
  class << self
    attr_accessor :current
  end

  attr_accessor :day_of_week, :hour, :minute, :time_type,
                :start_hour, :start_minute, :end_hour, :end_minute,
                :end_time, :week,
                :activity

  def initialize(activity)
    @activity = activity
    @end_time = current_week_end
    @week = []
    n = 4
    while n >= 0
      daytime = @end_time - (n*86400)
      week[n] = mk_day(daytime.year, daytime.month, daytime.day, 8, 0, 17, 0)
      n -= 1
    end
    UIState.current = self
  end

  def mk_day(year, month, day, start_hour, start_min, end_hour, end_min)
    [
        Time.new(year, month, day, start_hour, start_min),
        Time.new(year, month, day, end_hour, end_min)
    ]
  end

  def update_day(day_of_week, hour, minute, time_type)
    @day_of_week = day_of_week
    @hour = hour
    @minute = minute
    @time_type = time_type
  end

  def current_week_end
    t = Time.now
    while t.wday != 0 do
      t += 86400 # 1 day
    end
    t
  end

  def day_range(range)
    return "Off" if range.nil?

    "#{range[0].hour.to_s.rjust(2,'0')}:#{range[0].min.to_s.rjust(2,'0')} - " +
        "#{range[1].hour.to_s.rjust(2,'0')}:#{range[1].min.to_s.rjust(2,'0')}"
  end

  MONTH = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

  def display_values
    @display ||= []
    update_display_values
  end

  def update_display_values
    newarr = [
        [day_range(week[0]), "Monday"],
        [day_range(week[1]), "Tuesday"],
        [day_range(week[2]), "Wednesday"],
        [day_range(week[3]), "Thursday"],
        [day_range(week[4]), "Friday"],
        [day_range(week[5]), "Saturday"],
        [day_range(week[6]), "Sunday"],
        ["#{end_time.day} #{MONTH[end_time.month]}", "Week Ending"],
        ["Send",""]
    ]
    newarr.each_with_index {|obj,n| @display[n] = obj}
    @display
  end
end