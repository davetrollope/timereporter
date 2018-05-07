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
      time_picker.show(getFragmentManager,"startTimePicker")
      return
    end

    if position == 8
      begin
        intent = Intent.new(Intent::ACTION_SENDTO)
        intent.setType("message/rfc822")
        intent.putExtra(Intent::EXTRA_EMAIL, ["recipient@example.com"])
        intent.putExtra(Intent::EXTRA_SUBJECT, "subject of email")
        intent.putExtra(Intent::EXTRA_TEXT, "body of email")
        Toast.makeText(self, "Switching to email", Toast::LENGTH_SHORT).show();

        startActivity(Intent.createChooser(intent, "Send mail..."))
      rescue Android::Content::ActivityNotFoundException
        Toast.makeText(self, "There are no email clients installed.", Toast::LENGTH_SHORT).show();
      end
    end
  end
end

class TwoLineAdapter < Android::Widget::BaseAdapter
  def getCount()
    UIState.current.display_values.size
  end

  def getItem(position)
    UIState.current.display_values[position][1]
  end

  def getItemId(position)
    position
  end

  def getView(position, convertView, parent)
    context = parent.context
    textView1 = Android::Widget::TextView.new(context)
    textView1.text = UIState.current.display_values[position][0]
    textView1.textSize = 32

    textView2 = Android::Widget::TextView.new(context)
    textView2.text = UIState.current.display_values[position][1]

    layout = Android::Widget::LinearLayout.new(context)
    layout.orientation = Android::Widget::LinearLayout::VERTICAL
    layout.addView(textView1,  Android::Widget::LinearLayout::LayoutParams.new(Android::View::ViewGroup::LayoutParams::WRAP_CONTENT, Android::View::ViewGroup::LayoutParams::WRAP_CONTENT))
    layout.addView(textView2,  Android::Widget::LinearLayout::LayoutParams.new(Android::View::ViewGroup::LayoutParams::MATCH_PARENT, Android::View::ViewGroup::LayoutParams::WRAP_CONTENT))
    layout
  end
end