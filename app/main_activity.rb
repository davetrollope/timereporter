Toast = Android::Widget::Toast
Intent = Android::Content::Intent

class MainActivity < Android::App::Activity
  attr_accessor :uistate, :display

  def onCreate(savedInstanceState)
    @storage = TRStorage.new
    @uistate = UIState.new(self)
    super

    list = Android::Widget::ListView.new(self)
    list.adapter = adapter
    list.onItemClickListener = self
    self.contentView = list
  end

  def adapter
    @adapter ||= TwoLineAdapter.new
  end

  def onItemClick(parent, view, position, id)
    puts "Clicked #{position}"
    if position < 7
      # Display time picker
      uistate.update_day position, uistate.week[position][0].hour, uistate.week[position][0].min, :start
      time_picker = TRTimePicker.new
      time_picker.show(getFragmentManager, "startTimePicker")
      return
    end

    if position == 8
      email_body = ""
      display = UIState.current_state.display_values

      display.each_with_index {|display, n|
        if n <= 6
          email_body += display[:secondary] + ": " + display[:primary] + "\n"
        end
      }
      puts email_body
      begin
        intent = Intent.new(Intent::ACTION_SENDTO)
        intent.setType("message/rfc822")
        intent.putExtra(Intent::EXTRA_EMAIL, ["paul@pdbrickwork.com"])
        intent.putExtra(Intent::EXTRA_SUBJECT, "Time Report")
        intent.putExtra(Intent::EXTRA_TEXT, email_body)
        Toast.makeText(self, "Switching to email", Toast::LENGTH_SHORT).show();

        startActivity(Intent.createChooser(intent, "Send mail..."))
      rescue Android::Content::ActivityNotFoundException
        Toast.makeText(self, "There are no email clients installed.", Toast::LENGTH_SHORT).show();
      end
    end
  end

  def toggle_state(position)
    uistate.update_day_state(position)
  end
end

class TwoLineAdapter < Android::Widget::BaseAdapter
  attr_accessor :button_map, :text_map, :context

  def getCount()
    UIState.current_state.display_values.size
  end

  def getItem(position)
    UIState.current_state.display_values[position][:secondary]
  end

  def getItemId(position)
    position
  end

  def onCheckedChanged(button, isChecked)
    puts "Checked #{isChecked} #{button} position #{self.button_map.indexOf(button)}"
    context.toggle_state(self.button_map.indexOf(button))
    UIState.current_state.activity.adapter.notifyDataSetChanged()

  end

  def onClick(view)
    puts "CLICK position #{self.text_map.indexOf(view)}"
    context.onItemClick(self.context, view, self.text_map.indexOf(view), nil)
  end

  def getView(position, convertView, parent)
    self.button_map ||= []
    self.text_map ||= []

    current_position_state = UIState.current_state.display_values[position]

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