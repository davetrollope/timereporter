TimePickerDialog = Android::App::TimePickerDialog

class TRTimePicker < Android::App::DialogFragment
  def onCreateDialog(savedInstanceState)
    uistate = UIState.current
    puts "DOW #{uistate.day_of_week} #{uistate.end_time}"

    day = uistate.week[uistate.day_of_week]
    entry_num = uistate.time_type == :start ? 0 : 1

    tpd = TimePickerDialog.new(getActivity, self, day[entry_num].hour, day[entry_num].min, true)
    if uistate.time_type == :start
      tpd.setTitle('Start Time')
    else
      tpd.setTitle('End Time')
    end
    tpd
  end

  def onTimeSet(view, hour, minute)
    uistate = UIState.current
    if uistate.time_type == :start
      day = uistate.week[uistate.day_of_week]

      uistate.start_hour = hour
      uistate.start_minute = minute
      uistate.update_day uistate.day_of_week, day[1].hour, day[1].min, :end
      time_picker = TRTimePicker.new
      time_picker.show(fragmentManager, "endTimePicker")
      return
    end

    uistate.end_hour = hour
    uistate.end_minute = minute

    # Move to UIState as update?
    current_day = uistate.week[uistate.day_of_week]
    uistate.week[uistate.day_of_week] = UIState.mk_day(current_day[0].year, current_day[0].month, current_day[0].day,
                                                       uistate.start_hour, uistate.start_minute,
                                                       uistate.end_hour, uistate.end_minute)

    uistate.update_day_state(uistate.day_of_week) if uistate.day_state[uistate.day_of_week] != :working
    uistate.update_display_values
    uistate.activity.adapter.notifyDataSetChanged()
    uistate.activity.storage.save_week_state
  end
end