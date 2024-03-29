require 'time'
require 'active_support/time'

# parse messages generated by the access software
class HomebusCtrlhAccess::Message
  attr_accessor :door, :action, :person, :timestamp
  attr_accessor :month, :day, :hour, :minute, :second

  def initialize(msg, year = Time.now.to_date.year)
    m = msg.match /(([A-Z][a-z][a-z]) ([\d| ]\d) (\d\d):(\d\d):(\d\d))/
    if m
      time_string = $1
      @month = $2
      @day = $3
      @hour = $4
      @minute = $5
      @second = $6
    else
      puts msg
      raise "no timestamp"
    end

    d = DateTime.parse "#{year} #{$1}"
    @timestamp = DateTime.new.in_time_zone('America/Los_Angeles').change(year: year, month: d.month, day: d.day, hour: d.hour, min: d.min, sec: d.sec)

    case msg
    when /(\S+ \S+)\W+has (\S+) (unit\d \S+ door|front craft lab)/
      @person = $1
      @action = $2
      @door = $3
    when /(unit\d \S+ door|front craft lab) (\S+) by (\S+ \S+)/
      @person = $3
      @action = $2
      @door = $1
    when /(\S+ \S+|\.)\W+found (\S+ \S+ \S+) is (already \S+)/
      @person = $1
      @action = $3
      @door = $2
    when /(\S+ \S+|\.)\W+(enabled|disabled) laser-access/
      @person = $1
      @action = $2
      @door = 'laser-access'
    when /A card was presented at (unit\d \S+ door|front craft lab) and access was denied/
      @person = nil
      @action = 'access denied'
      @door = $1
    when /(\S+) reloading access list/
      @person = nil
      @action = 'reloading access list'
      @door = $1
    when /(\S+) access control is (online|going offline)/
      @person = nil
      @action = $2
      @door = $1
    when /Initializing/
      @person = nil
      @action = 'initializing'
      @door = nil
    when /laser-access starting up!/
      @person = nil
      @action = 'starting up'
      @door = 'laser-access'
    else
      @person = nil
      @action = msg
      @door = nil
    end

    trim_last_name
  end

  def trim_last_name
    return  unless @person

    m = @person.match /(\S+) (\S+)/
    if m
      @person = m[1] + ' ' + m[2][0, 1] + '.'
    end
  end
end
