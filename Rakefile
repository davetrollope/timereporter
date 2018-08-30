# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/android'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'TimeReporter'
  app.package = 'com.fsmltechnologies.timereporter'
  app.api_version = "22"
  app.target_api_version = "26"
  app.icon = 'chronograph'
  # https://github.com/HipByte/Flow/pull/64
  app.assets_dirs.delete('resources')
  app.resources_dirs << './resources'
  app.version_code = 1
  app.version_name = "1.0"

  app.release_keystore("/Users/dave/keystores/timereporter.keystore", "timereporter_key")
end
