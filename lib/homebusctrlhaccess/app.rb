require 'homebus'
require 'homebus/state'

require 'homebusctrlhaccess/message'

class HomebusCtrlhAccess::App < Homebus::App
  DDC = 'org.pdxhackerspace.experimental.access'
  DOORS = [ "front craft lab",  "laser-access",  "unit2",  "unit2 front door",  "unit3 back door", "all"]

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
      if @options[:verbose]
        puts 'no access message'
      end
      exit
    end

    msg = HomebusCtrlhAccess::Message.new access_msg

    unless msg.door
      if @options[:verbose]
        puts 'no door'
      end
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
      @state.state[:history][msg.door.to_sym].shift
    end

    if payload[:door] != 'laser-access'
      @state.state[:history][:all].push(payload.clone)
      if(@state.state[:history][:all].length > 10) then
        @state.state[:history][:all].shift
      end
    end

    @state.commit!

    payload[:history] = @state.state[:history][msg.door.to_sym]
    if @options[:verbose]
      pp payload
    end

    device = _find_door(msg.door)
    if device
      device.publish! DDC, payload
    else
      if @options[:verbose]
        puts 'no device found'
      end
    end

    device = _find_door('all')
    if device
      payload[:history] = @state.state[:history][:all]
      if @options[:verbose]
        pp payload
      end

      device.publish! DDC, payload
    else
      if @options[:verbose]
        puts '"all" not found'
      end
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
