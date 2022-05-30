#!/usr/bin/env ruby

# coding: utf-8

require './options'
require './app'

require 'net/http'
require 'json'
require 'date'
require 'pp'

require './message'

class BackfillCtrlhAccessHomebusApp < AccessHomebusApp
  BACKFILL_FILENAME = 'access-control.log'
  START_YEAR = 2016
  DDC = 'org.pdxhackerspace.experimental.access'

  def setup
  end

  def _get_data
    puts '_get_data'

    year = START_YEAR
    current_month = ''

    unless File.exists? BACKFILL_FILENAME
      raise 'missing access-control.log file'
    end

    File.readlines(BACKFILL_FILENAME).each { |line|
      puts line

      msg = AccessMessage.new line, year
      if current_month == 12 && msg.timestamp.month == 1
        year += 1
        msg.timestamp.change(year: year)
      end

      current_month = msg.timestamp.month

      yield msg
    }

    puts 'done'
  end

  def _find_door(door_name)
    devices.select { |d| d.serial_number == door_name }[0]
  end

  def work!
    _get_data do |msg|
      timestamp = msg.timestamp.to_time.to_i

      data = {
        door: msg.door,
        action: msg.action,
        person: msg.person,
        timestamp: timestamp
      }

      next unless msg.door

      device = _find_door(msg.door)
      unless device
        next
      end

      pp device, timestamp, data

      device.publish! DDC, data, timestamp
    end

    puts 'backfill complete'
    exit
  end
end


#cvan_app_options = COVIDActNowHomebusAppOptions.new

# cvan = BackfillCtrlhAccessHomebusApp.new cvan_app_options.options
cvan = BackfillCtrlhAccessHomebusApp.new Hash.new
cvan.run!
#cvan.setup!
#cvan.work!
