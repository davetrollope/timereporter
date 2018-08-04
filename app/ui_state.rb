
class UIState
  class << self
    def current_state
      @@current_state
    end
    def current_state=(val)
      @@current_state = val
    end
  end

  attr_accessor :day_of_week, :hour, :minute, :time_type,
                :start_hour, :start_minute, :end_hour, :end_minute,
                :end_time, :week, :day_state,
                :activity, :reporting_email

  def initialize(an_activity)
    @activity = an_activity
    @end_time = current_week_end
    @week = []
    @day_state = []
    @reporting_email = ''

    n = 6
    while n >= 0
      daytime = @end_time - ((6 - n) * 86400)
      week[n] = mk_day(daytime.year, daytime.month, daytime.day, 8, 0, 17, 0)
      day_state[n] = :working if n < 5
      n -= 1
    end

    UIState.current_state = self
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

  def update_day_state(position)
    day_state[position] = day_state[position] ? nil : :working
  end

  def update_week_end(new_end)
    @end_time = Time.parse(new_end)
  end

  def current_week_end
    t = Time.now
    while t.wday != 0
      t += 86400 # 1 day
    end
    t
  end

  def day_range(range)
    "#{range[0].hour.to_s.rjust(2,'0')}:#{range[0].min.to_s.rjust(2,'0')} - " +
        "#{range[1].hour.to_s.rjust(2,'0')}:#{range[1].min.to_s.rjust(2,'0')}"
  end

  def day_primary_text(position)
    day_state[position] == :working ? day_range(week[position]) : "Off"
  end
  MONTH = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

  def display_values
    @display ||= []
    update_display_values
  end

  def update_display_values
    newarr = [
      {primary: day_primary_text(0), secondary: "Monday", state: day_state[0]},
      {primary: day_primary_text(1), secondary: "Tuesday", state: day_state[1]},
      {primary: day_primary_text(2), secondary: "Wednesday", state: day_state[2]},
      {primary: day_primary_text(3), secondary: "Thursday", state: day_state[3]},
      {primary: day_primary_text(4), secondary: "Friday", state: day_state[4]},
      {primary: day_primary_text(5), secondary: "Saturday", state: day_state[5]},
      {primary: day_primary_text(6), secondary: "Sunday", state: day_state[6]},
      {primary: "#{end_time.day} #{MONTH[end_time.month - 1]}", secondary: "Week Ending"},
      {primary: "Send", secondary: ""}
    ]
    newarr.each_with_index {|obj, n| @display[n] = obj}
    @display
  end

  def week_hash
    {
        week_end: end_time,
        days: display_values.map do |display_value|
          { text: display_value[:primary], state: display_value[:state] }
        end
    }
  end

  def static_hash
    {
      reporting_email: reporting_email,
      current_week: end_time
    }
  end
end