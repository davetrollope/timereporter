class TREmailInput < Android::App::DialogFragment

  def onCreateDialog(savedInstanceState)
    uistate = UIState.current

    email_input = Android::Widget::EditText.new(uistate.activity)
    email_input.text = uistate.reporting_email
    email_input.maxLines = 1
    email_input.inputType = Android::Text::InputType::TYPE_TEXT_VARIATION_EMAIL_ADDRESS
    email_input.addTextChangedListener(EmailTextWatcher.new)

    dialog = Android::App::Dialog.new uistate.activity
    dialog.contentView = email_input
    dialog.setTitle 'Email to: (tap to continue)'
    dialog.cancelable = true
    dialog
  end

  def onDismiss(this)
    uistate = UIState.current
    uistate.activity.storage.save_static_state
    return if uistate.reporting_email == ''
    UIState.current.activity.send_email
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
