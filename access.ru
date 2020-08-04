require 'sinatra/base'
require 'mqtt'

require 'json'

require './message'

class AccessWebhook < Sinatra::Base
  CONFIG_FILE='.access.json'
  DDC = 'org.pdxhackerspace.experimental.access'

  homebus_config = []

  if File.exists? CONFIG_FILE
    f = File.open CONFIG_FILE, 'r'
    homebus_config = JSON.parse f.read, symbolize_names: true
    f.close
  else
    abort "no config file"
  end

  c = homebus_config[0]

  mqtt = MQTT::Client.connect(c[:mqtt_server], port: c[:mqtt_port], username: c[:mqtt_username], password: c[:mqtt_password])

  post '/' do
    content_type :json

    request.body.rewind
    body = request.body.read
    results = JSON.parse(body, symbolize_names: true)
    msg = AccessMessage.new results[:text]

    configs = homebus_config.select { |x| x[:door] == msg.door }
    if configs.first
      uuid = configs.first[:uuid]
      timestamp = Time.now.to_i

      m = { source: uuid,
            timestamp: timestamp,
            contents: {
              ddc: DDC,
              payload: {
                door: msg.door,
                action: msg.action,
                person: msg.person,
                timestamp: timestamp
              }
            }
          }

      mqtt.publish 'homebus/device/' + uuid + '/' + DDC,
                   JSON.pretty_generate(m),
                   true

#      publish! JSON.pretty_generate(m)
    else
      m[:error] = true
      m[:msg] = "Cannot find door #{msg.door}"

      mqtt.publish '/homebus/device/' + uuid + '/error',
                   JSON.pretty_generate(m),
                   true
    end
  end
end

run AccessWebhook
