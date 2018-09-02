Toast = Android::Widget::Toast
Intent = Android::Content::Intent

class MainActivity < Android::App::Activity
  attr_accessor :uistate, :display, :storage

  def onCreate(savedInstanceState)
    puts "NEW ACTIVITY"
    Android::Util::Log.i "TimeReporter::MainActivity#onCreate", "init"
    @storage = TRStorage.new self
    Android::Util::Log.i "TimeReporter::MainActivity#onCreate", "init state"
    @uistate = UIState.new(self)
    Android::Util::Log.i "TimeReporter::MainActivity#onCreate", "super"
    super

    Android::Util::Log.i "TimeReporter::MainActivity#onCreate", "list"
    list = Android::Widget::ListView.new(self)
    list.adapter = adapter
    list.onItemClickListener = self
    self.contentView = list
    Android::Util::Log.i "TimeReporter::MainActivity#onCreate", "start"
  end

  def adapter
    @adapter ||= TwoLineAdapter.new
  end

  def onItemClick(parent, view, position, id)
    if position < 7
      # Display time picker
      uistate.update_day position, uistate.week[position][0].hour, uistate.week[position][0].min, :start
      time_picker = TRTimePicker.new
      time_picker.show(getFragmentManager, "startTimePicker")
      return
    end

    if position == 7
      storage.save_week_state
      week_picker = TRWeekPicker.new
      week_picker.show(getFragmentManager, "startWeekPicker")
      return
    end

    if position == 8
      storage.save_week_state
      email_input = TREmailInput.new
      email_input.show(getFragmentManager, "startEmailInput")
    end
  end

  def send_email
    display = UIState.current.display_values
    email_body = "Week Ending: #{UIState.current.current_week_id}\n"

    display.each_with_index {|display, n|
      if n <= 6
        email_body += display[:secondary] + ": " + display[:primary] + "\n"
      end
    }

    email_body += "Total Time: #{UIState.interval_string(UIState.current.total_time)}\n"
    puts "EMAIL:\n#{email_body}"

    begin
      mailto = "mailto:#{uistate.reporting_email}" +
          "?subject=" + Android::Net::Uri.encode("Time Report") +
          "&body=" + Android::Net::Uri.encode(email_body)

      intent = Intent.new(Intent::ACTION_SENDTO)
      intent.setData(Android::Net::Uri.parse(mailto.toString))

      Toast.makeText(self, "Switching to email", Toast::LENGTH_SHORT).show();

      startActivity(intent)
    rescue Android::Content::ActivityNotFoundException
      Toast.makeText(self, "There are no email clients installed.", Toast::LENGTH_SHORT).show();
    end
  end

  def toggle_state(position)
    uistate.update_day_state(position)
  end
end

class TwoLineAdapter < Android::Widget::BaseAdapter
  attr_accessor :button_map, :text_map, :context

  def getCount
    UIState.current.display_values.size
  end

  def getItem(position)
    UIState.current.display_values[position][:secondary]
  end

  def getItemId(position)
    position
  end

  def onCheckedChanged(button, isChecked)
    context.toggle_state(button_map.indexOf(button))
    UIState.current.activity.adapter.notifyDataSetChanged()
  end

  def onClick(view)
    context.onItemClick(self.context, view, text_map.indexOf(view), nil)
  end

  def getView(position, convertView, parent)
    self.button_map ||= []
    self.text_map ||= []

    current_position_state = UIState.current.display_values[position]

    self.context = context = parent.context
    textView1 = Android::Widget::TextView.new(context)
    textView1.text = current_position_state[:primary]
    textView1.textSize = 32
    textView1.onClickListener = self
    textView1.clickable = true
    self.text_map[position] = textView1

    textView2 = Android::Widget::TextView.new(context)
    textView2.text = current_position_state[:secondary]

    hlayout = Android::Widget::LinearLayout.new(context)
    hlayout.orientation = Android::Widget::LinearLayout::HORIZONTAL
    if position <= 6
      toggle = Android::Widget::ToggleButton.new(context)
      toggle.textOn = 'Working'
      toggle.checked = current_position_state[:state] == :working
      toggle.onCheckedChangeListener = self
      self.button_map[position] = toggle

      hlayout.addView(toggle, Android::Widget::LinearLayout::LayoutParams.new(Android::View::ViewGroup::LayoutParams::WRAP_CONTENT, Android::View::ViewGroup::LayoutParams::WRAP_CONTENT))
    end

    layout = Android::Widget::LinearLayout.new(context)
    layout.orientation = Android::Widget::LinearLayout::VERTICAL
    layout.addView(textView1, Android::Widget::LinearLayout::LayoutParams.new(Android::View::ViewGroup::LayoutParams::MATCH_PARENT, Android::View::ViewGroup::LayoutParams::WRAP_CONTENT))
    layout.addView(textView2, Android::Widget::LinearLayout::LayoutParams.new(Android::View::ViewGroup::LayoutParams::MATCH_PARENT, Android::View::ViewGroup::LayoutParams::WRAP_CONTENT))

    hlayout.addView(layout)

    hlayout
  end
end