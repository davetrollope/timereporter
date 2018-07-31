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
    # Why didn't I just use Time as in UIState?
    cal = Java::Util::Calendar.getInstance
    # Move to Sunday
    while cal.wday != 0
      cal.add(Java::Util::Calendar::DAY_OF_YEAR, 1)
    end
    cal.add(Java::Util::Calendar::WEEK_OF_YEAR, -5)
    @week_list = Array.new(6).map {
      cal.add(Java::Util::Calendar::WEEK_OF_YEAR, 1)
      date_format.format(cal.getTime)
    }

    Android::Widget::ArrayAdapter.new(getActivity, Android::R::Layout::Simple_list_item_1, @week_list)
  end

  def onItemClick(parent, view, position, id)
    uistate = UIState.current_state
    date = date_format.parse(@week_list[position])
    uistate.end_time = Time.new(date.year + 1900, date.month, date.date)
    uistate.update_display_values
    uistate.activity.adapter.notifyDataSetChanged()
    self.dismiss
  end
end
