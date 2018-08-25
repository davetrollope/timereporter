class TRStorage
  attr_reader :context

  STATICDATA_FILENAME = 'staticdata.json'

  def initialize(context)
    @context = context
  end

  def load_static_data
    dirlist = context.fileList()
    puts "DIRLIST #{dirlist}"
    if dirlist.include? STATICDATA_FILENAME
      input_file = context.openFileInput(STATICDATA_FILENAME)
      br = Java::IO::BufferedReader.new(Java::IO::InputStreamReader.new(input_file))
      static_str = br.readLine
      @json = JSON.load(static_str)
    else
      # Nothing to do
      @json = nil
    end
    puts "READ STATIC JSON #{@json}"
    @json
  end

  def load_week_data(week_id)
    puts "LOADING #{week_id}"
    filename = "#{week_id}.json"

    input_file = context.openFileInput(filename)
    br = Java::IO::BufferedReader.new(Java::IO::InputStreamReader.new(input_file))
    @week_json = JSON.load(br.readLine)
    puts "READ WEEK JSON #{@week_json}"

    @end_time = UIState.parse_week_end(week_id)
    @daytime = @end_time - (6 * 86400) # 6 days
    @week = []
    @day_state = []

    @week_json["days"].each_with_index do |day_data, n|
      if day_data['text'].include? '-'
        ranges = day_data['text'].split('-').map {|v| v.strip}
        am = ranges[0].split(':')
        pm = ranges[1].split(':')

        @week[n] = UIState.mk_day(@daytime.year, @daytime.month, @daytime.day,
                                  am[0].to_i, am[1].to_i, pm[0].to_i, pm[1].to_i)
        @daytime += 86400 # 1 day

        @day_state[n] = :working if day_data["state"] == "working"
      else
        @week[n] = UIState.default_day(@end_time, n)
      end
    end

    @current_week = {week_id: week_id, end_time: @end_time, week: @week, day_state: @day_state}
  rescue Java::IO::FileNotFoundException => e
    puts "#{filename} does not exist, continuing"
    { week: nil, daytime: nil }
  end

  def save_static_state
    uistate = UIState.current
    @end_time = uistate.end_time
    @static_json = uistate.static_hash.to_json
    puts "SAVE STATIC JSON #{@static_json}"
    write_json(STATICDATA_FILENAME, @static_json.toString)
  end

  def save_week_state
    week_json = UIState.current.week_hash.to_json
    current_week_id = UIState.current.current_week_id
    puts "SAVE WEEK JSON #{current_week_id}"
    write_json("#{current_week_id}.json", week_json.toString)
  end

  private

  def write_json(filename, json_str)
    json_file = context.openFileOutput(filename, context.MODE_PRIVATE)

    # Because RM doesn't convert bytes to an array, only arraylists so the signature doesn't match
    # static_file.write(static_str.getBytes)
    osw = Java::IO::OutputStreamWriter.new(json_file)
    osw.write(json_str, 0, json_str.length)
    #puts "WROTE #{json_str}"

    osw.close()
    json_file.close()
  end

  def self.clear_files(context)
    dirlist = context.fileList()
    puts "DIRLIST #{dirlist}"
    dirlist.each do |file|
      context.deleteFile file
    end
  end
end