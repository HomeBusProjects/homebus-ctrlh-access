#!/usr/bin/env ruby

require './options'
require './app'

access_app_options = AccessHomebusAppOptions.new

access = AccessHomebusApp.new access_app_options.options
access.run!
