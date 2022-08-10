#!/usr/bin/env ruby

require '../lib/options'
require '../lib/app'

access_app_options = AccessHomebusAppOptions.new

access = AccessHomebusApp.new access_app_options.options
access.run!
