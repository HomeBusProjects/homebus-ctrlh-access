#!/usr/bin/env ruby

require 'homebus'

class ProvisionCtrlhAccess < Homebus::App
  DDC = 'org.pdxhackerspace.experimental.access'

  def setup!
    @devices = []

    [ "front craft lab",  "laser-access",  "unit2",  "unit2 front door",  "unit3 back door"].each do |door|
      @devices.push(Homebus::Device.new(name: door,
                                        manufacturer: "Homebus",
                                        model: "CTRLH Access",
                                        serial_number: door))
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
