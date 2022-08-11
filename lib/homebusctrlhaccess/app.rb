require 'homebus'
require 'homebus/state'

require 'homebusctrlhaccess/message'

class HomebusCtrlhAccess::App < Homebus::App
  DDC = 'org.pdxhackerspace.experimental.access'
  DOORS = [ "front craft lab",  "laser-access",  "unit2",  "unit2 front door",  "unit3 back door"]

  def setup!
    @devices = []

    if !@state.state[:history]
      @state.state[:history] = Hash.new
      @state.commit!
    end

    DOORS.each do |door|
      @devices.push(Homebus::Device.new(name: door,
                                        manufacturer: "Homebus",
                                        model: "CTRLH Access",
                                        serial_number: door))

      if !@state.state[:history][door.to_sym] then
        @state.state[:history][door.to_sym] = Array.new
        @state.commit!
      end
    end
  end

  def _find_door(door_name)
    devices.select { |d| d.serial_number == door_name }[0]
  end

  def work!
    access_msg = gets

    if access_msg == nil
      exit
    end

    msg = HomebusCtrlhAccess::Message.new access_msg

    unless msg.door
      return
    end

    payload = {
      door: msg.door,
      action: msg.action,
      person: msg.person,
      timestamp: msg.timestamp
    }

    @state.state[:history][msg.door.to_sym].push(payload.clone)
    if(@state.state[:history][msg.door.to_sym].length > 10) then
      @state.state[:history][msg.door.to_sym].unshift
    end

    @state.commit!

    payload[:history] = @state.state[:history][msg.door.to_sym]

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
