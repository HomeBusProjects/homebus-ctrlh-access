#!/usr/bin/env ruby

require 'homebus'
require 'homebus/state'

require './message'

class AccessHomebusApp < Homebus::App
  DDC = 'org.pdxhackerspace.experimental.access'
  DOORS = [ "front craft lab",  "laser-access",  "unit2",  "unit2 front door",  "unit3 back door"]

  def setup!
    @devices = []

    DOORS.each do |door|
      @devices.push(Homebus::Device.new(name: door,
                                        manufacturer: "Homebus",
                                        model: "CTRLH Access",
                                        serial_number: door))
    end

    @state = Homebus::State.new
    @store = @state.store
  end

  def _find_door(door_name)
    devices.select { |d| d.serial_number == door_name }[0]
  end

  def work!
    access_msg = gets

    if access_msg == nil
      exit
    end

    msg = AccessMessage.new access_msg

    payload = {
      door: msg.door,
      action: msg.action,
      person: msg.person,
      timestamp: msg.timestamp
    }

    unless msg.door
      return
    end

    device = _find_door(msg.door)
    if device
      device.publish! DDC, payload
    end
  end

  def name
    'PDX Hackerspace Access Control'
  end

  def publishes
    [ DDC ]
  end

  def devices
    @devices
  end
end
