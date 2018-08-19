class TRWeekPicker < Android::App::DialogFragment

  def onCreateDialog(savedInstanceState)
    uistate = UIState.current

    list = Android::Widget::ListView.new(uistate.activity)
    list.adapter = adapter
    list.onItemClickListener = self

    dialog = Android::App::Dialog.new uistate.activity
    dialog.contentView = list
    dialog.setTitle 'Week Ending:'
    dialog.cancelable = true
    dialog
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
      UIState.date_format.format(cal.getTime)
    }

    Android::Widget::ArrayAdapter.new(getActivity, Android::R::Layout::Simple_list_item_1, @week_list)
  end

  def onItemClick(parent, view, position, id)
    UIState.current.switch_weeks @week_list[position]
    self.dismiss
  end
end
