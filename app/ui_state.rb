
class UIState
  class << self
    def current
      @@current_state
    end
    def current=(val)
      @@current_state = val
    end
  end

  attr_accessor :day_of_week, :hour, :minute, :time_type,
                :start_hour, :start_minute, :end_hour, :end_minute,
                :end_time, :week, :day_state,
                :activity, :reporting_email, :alert_button_id

  def initialize(an_activity)
    @activity = an_activity
    @static_json = activity.storage.load_static_data
    @alert_button_id = nil # For TREmailInput to survive rotation, does not need persisting

    if @static_json
      @day_of_week = @static_json['day_of_week'] if @static_json['day_of_week']
      @time_type = @static_json['time_type'].to_sym if @static_json['time_type']
      @start_hour = @static_json['start_hour'] if @static_json['start_hour']
      @start_minute = @static_json['start_minute'] if @static_json['start_minute']
    end

    @reporting_email = @static_json && @static_json['reporting_email'] ? @static_json['reporting_email'] : ''
    if @static_json && @static_json['current_week']
      @end_time = UIState.parse_week_end(@static_json['current_week'])
      load_week @static_json['current_week']
    else
      @end_time = current_week_end
    end
    @static_json = {'week' => [], 'current_week' => current_week_id} if @static_json.nil?

    if @week.nil?
      @end_time = current_week_end
      default_week
    end

    UIState.current = self
  end

  def self.mk_day(year, month, day, start_hour, start_min, end_hour, end_min)
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
    activity.storage.save_static_state
  end

  def update_day_state(position)
    day_state[position] = day_state[position] ? nil : :working
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

  def current_week_id
    "#{MONTH[end_time.month - 1][0..2]} #{end_time.day}, #{end_time.year}"
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
      week_end: current_week_id,
      days: display_values.map do |display_value|
        { text: display_value[:primary], state: display_value[:state] }
      end
    }
  end

  def static_hash
    {
      reporting_email: reporting_email,
      current_week: current_week_id,

      # Needed when presenting a dialog and a screen rotation occurs
      day_of_week: day_of_week,
      time_type: time_type,
      start_hour: start_hour,
      start_minute: start_minute
    }
  end

  def self.date_format
    @@dateformat ||= Java::Text::SimpleDateFormat.new("MMM d, yyyy")
  end

  def self.parse_week_end(end_str)
    date = date_format.parse(end_str)
    Time.new(date.year + 1900, date.month, date.date)
  end

  def switch_weeks(new_week_id)
    @end_time = UIState.parse_week_end(new_week_id)
    activity.storage.save_static_state
    @static_json['current_week'] = new_week_id
    load_week new_week_id
    update_display_values
    activity.adapter.notifyDataSetChanged()
  end

  def self.default_day(end_time, n)
    daytime = end_time - ((6 - n) * 86400)
    UIState.mk_day(daytime.year, daytime.month, daytime.day, 8, 0, 17, 0)
  end

  def self.interval_string(interval)
    hours = (interval / 60 / 60).to_i
    mins = (interval / 60 % 60).to_i
    return "None" if hours + mins == 0
    
    mins == 0 ? "#{hours} hour#{pluralize(hours)}" : "#{hours} hours #{mins} min#{pluralize(mins)}"
  end

  def total_time
    week.map.with_index do |day, n|
      if n <= 6 && day_state[n] == :working
        day[1] - day[0]
      else
        0
      end
    end.inject :+
  end

  private

  def default_week
    @week = []
    @day_state = []

    n = 6
    while n >= 0
      @week[n] = UIState.default_day(@end_time, n)
      day_state[n] = :working if n < 5
      n -= 1
    end
  end

  def load_week(week_id)
    @week_info = activity.storage.load_week_data(week_id)
    @week = @week_info[:week]
    @day_state = @week_info[:day_state]
    default_week if @week.nil?
    puts "LOAD #{@week} #{@day_state}"
  end

  def self.pluralize(val)
    val > 1 ? 's' : ''
  end
end