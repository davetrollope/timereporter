class TRStorage
  attr_reader :weeks

  def initialize
    # Will load existing stored data, but for now, all new.
    @weeks = {}
  end

  def set_week_of(week_ending, day, start_hour, start_minute, end_hour, end_minute)
    weeks[week_ending] = {:position => [start_hour, start_minute, end_hour, end_minute]}
  end

  def default_day
    [8, 0, 5, 0]
  end
end