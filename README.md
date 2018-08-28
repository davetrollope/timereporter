# Time Reporter

This is an example app for the Android platform built with [RubyMotion](http://www.rubymotion.com)

I built it as my first Android app and thus I share it for other newcomers to the RubyMotion ecosystem

I don't claim it to be the best way to implement this app, its version 1!

The inspiration came from a family member who needed a simple time sheet type app to replace
the facebook group his employees were using to report time to him. While there are
many apps out there for time reporting, many are tied to bigger systems and cloud
services which he did not need.

## Functionality

The App is designed to allow a user to send an email report of their weekly timesheet.

For each day of the week you can:
* mark a day as working or off.
* set the start and end time for the day
* Send email with the timesheet

## Components Used

### Android
* TimePickerDialog
* Dialog
* AlertDialog Builder
* ListView
* TextView
* EditText Widget
* Email (SENDTO) Intent
* LinearLayout
* FileInput / FileOutput
* InputStreamReader / OutputStreamWriter

### Java
* SimpleDateFormat
* Calendar

### Ruby
* [Flow](https://github.com/HipByte/Flow) (for JSON)



