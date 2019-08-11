#!/usr/bin/env ruby

require 'homebus'

require 'json'
require 'pp'

CONFIG_FILE='.access.json'

homebus_config = []

if File.exists? CONFIG_FILE
  f = File.open CONFIG_FILE, 'r'
  homebus_config = JSON.parse f.read, symbolize_names: true
  f.close
end

def provision(location)
  provision_request = {
    friendly_name: 'PDX Hackerspace Access Control',
    friendly_location: 'Portland, OR',
    manufacturer: 'Homebus',
    model: 'Access Control',
    pin: 0,
    serial_number: location,
    devices: [ {
                 friendly_name: 'Door',
                 friendly_location: location,
                 update_frequency: 0,
                 index: 0,
                 accuracy: 0,
                 precision: 0,
                 wo_topics: [ 'access' ],
                 ro_topics: [],
                 rw_topics: []
               }
             ]
  }

  HomeBus.provision provision_request
end

doors = [ "front craft lab",  "laser-access",  "unit2",  "unit2 front door",  "unit3 back door"]

auth_struct = []

doors.each do |door|
  results = provision door
  pp results

  auth_struct.push(  { uuid: results[:uuid],
                      mqtt_server: results[:host],
                      mqtt_port: results[:port],
                      mqtt_username: results[:username],
                      mqtt_password: results[:password],
                      door: door })
end

File.open(CONFIG_FILE, 'w') do |f| f.write(JSON.pretty_generate(auth_struct)) end
