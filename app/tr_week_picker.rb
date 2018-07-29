class TRWeekPicker < Android::App::DialogFragment

  def onCreateDialog(savedInstanceState)
    uistate = UIState.current_state

    list = Android::Widget::ListView.new(uistate.activity)
    list.adapter = adapter
    list.onItemClickListener = self

    dialog = Android::App::Dialog.new uistate.activity
    dialog.contentView = list
    dialog.setTitle 'Week Ending:'
    dialog.cancelable = true
    dialog
  end

  def date_format
    @dateformat ||= Java::Text::SimpleDateFormat.new("MMM dd, yyyy")
  end

  def adapter
    now = Java::Util::Date.new

    @week_list = [-4, -3, -2, -1, 0, 1].map {|offset|
      cal = Java::Util::Calendar.getInstance
      cal.setTime(now)
      cal.add(Java::Util::Calendar::WEEK_OF_YEAR, offset)
      date_format.format(cal.getTime)
    }

    Android::Widget::ArrayAdapter.new(UIState.current_state.activity, Android::R::Layout::Simple_list_item_1, @week_list)
  end

  def onItemClick(parent, view, position, id)
    puts "Clicked week #{position} #{@week_list[position]}"
    uistate = UIState.current_state
    uistate.end_time = date_format.parse(@week_list[position])
    uistate.update_display_values
    uistate.activity.adapter.notifyDataSetChanged()
    self.dismiss
  end
end
