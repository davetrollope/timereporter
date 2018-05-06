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
    @adapter ||= Android::Widget::ArrayAdapter.new(self, Android::R::Layout::Simple_list_item_1, uistate.display_values)
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
