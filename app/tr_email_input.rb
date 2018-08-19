class TREmailInput < Android::App::DialogFragment

  class << self
    def send_email
      @@send_email
    end
    def send_email=(val)
      @@send_email = val
    end
  end

  def onCreateDialog(savedInstanceState)
    @@send_email = false

    uistate = UIState.current

    builder = Android::App::AlertDialog::Builder.new(uistate.activity)
    inflater = uistate.activity.getLayoutInflater
    builder.setMessage('Email to:')
    builder.setPositiveButton(Android::R::String::Ok, EmailDialogInterface.new)
    builder.setNegativeButton(Android::R::String::Cancel, EmailDialogInterface.new)

    email_input = Android::Widget::EditText.new(uistate.activity)
    email_input.text = uistate.reporting_email
    email_input.maxLines = 1
    email_input.inputType = Android::Text::InputType::TYPE_TEXT_VARIATION_EMAIL_ADDRESS
    email_input.addTextChangedListener(EmailTextWatcher.new)

    builder.setView(email_input)

    builder.create()
  end

  def onDismiss(this)
    uistate = UIState.current
    uistate.activity.storage.save_static_state
    puts "DISMISS #{uistate.reporting_email} #{TREmailInput.send_email}"
    return if uistate.reporting_email == ''
    UIState.current.activity.send_email if TREmailInput.send_email
  end
end

class EmailTextWatcher
  def afterTextChanged(editable)
  end

  def beforeTextChanged(str, start, count, after)
  end

  def onTextChanged(s, start, before, count)
    #puts "TEXT CHANGED #{s.toString} #{start} #{before} #{count}"
    UIState.current.reporting_email = s.toString
  end
end

class EmailDialogInterface
  def onClick(dialog, id)
    puts "DIALOG CLICK ID #{id == -1}"
    TREmailInput.send_email = id == -1
    dialog.dismiss
  end
end
