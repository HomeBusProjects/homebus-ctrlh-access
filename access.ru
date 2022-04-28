#!/usr/bin/env ruby

require 'sinatra'
require 'json'

require 'homebus'

require './message'

class AccessHomebusApp < Homebus::App
  DDC = 'org.pdxhackerspace.experimental.access'
  DOORS = [ "front craft lab",  "laser-access",  "unit2",  "unit2 front door",  "unit3 back door"]

  def setup!
    @devices = []

    [ "front craft lab",  "laser-access",  "unit2",  "unit2 front door",  "unit3 back door"].each do |door|
      @devices.push(Homebus::Device.new(name: door,
                                        manufacturer: "Homebus",
                                        model: "CTRLH Access",
                                        serial_number: door))
    end
  end

  def work!
    run AccessWebhook
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

  def find_door(door_name)
    devices.select { |d| d.serial_number == door_name }[0]
  end
end

class AccessWebhook < Sinatra::Application
  post '/' do
    content_type :json

    request.body.rewind
    body = request.body.read
    results = JSON.parse(body, symbolize_names: true)
    msg = AccessMessage.new results[:text]
    msg = {
      door: msg.door,
      action: msg.action,
      person: msg.person,
      timestamp: timestamp
    }

    device = find_door msg.door
    if device
      if !device.connected?
        device.connect!
      end

      device.publish! DDC, msg
    else
      puts "unknown door #{msg.door}"
    end
  end
end

