class TREmailInput < Android::App::DialogFragment

  def onCreateDialog(savedInstanceState)
    uistate = UIState.current

    builder = Android::App::AlertDialog::Builder.new(uistate.activity)
    builder.setMessage('Email to:')
    builder.setPositiveButton(Android::R::String::Ok, self)
    builder.setNegativeButton(Android::R::String::Cancel, self)

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

    send_email = uistate.alert_button_id == -1
    puts "DISMISS #{uistate.reporting_email} #{send_email}"
    return if uistate.reporting_email == ''
    UIState.current.activity.send_email if send_email
  end

  def onClick(dialog, id)
    UIState.current.alert_button_id = id
    dismiss
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

