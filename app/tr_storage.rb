class TRStorage

  def initialize(context)
    load_data context
  end

  def load_data(context)
    dirlist = context.fileList()
    if dirlist.include? 'data.json'
      input_file = context.openFileInput('data.json')
    else
      # Nothing to do
      puts "No data to load"
    end
  end

  def save_state

  end
end