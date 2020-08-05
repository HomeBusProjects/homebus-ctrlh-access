# homebus-ctrlh-access

A Homebus publisher which publishes access control logs from ^H's doors.

The software provides webhook which receives a string from the access control software.
It parses the string and publishes it to the correct Homebus device for the door that was used.

Each door is a separate Homebus device so that doors may be individually monitored. This makes it
easy to determine whether a door is currently locked or unlocked.

If you're not with [PDX Hackerspace](https://pdxhackerspace.org) (otherwise known as ^H), this software is probably not useful to you beyond being a simple example  of how to integrate a webhook with Homebus.

## Setup

1. Clone the repository.
```
git clone https://github.com/HomeBusProjects/homebus-ctrlh-access
cd homebus-ctrlh-access
```

2. Install the needed gems
```
bundle install
```

3. Provision the publisher
```
bundle exec ./provision -b localhost -P 80
```

This will generate a Homebus provisioning request for each door. The list of doors is embedded in the software. You may need to change `localhost` and `80` to be the correct name or IP address and port number of the Homebus provisioner for your system.

4. Run the webhook server
```
bundle exec puma -p 9393 access.ru
```

This tells Puma to execute the Sinatra app in access.ru and bind it to port 9393. The Nginx configuration file in step 5 depends on port number 9393; if you change the port you'll need to change the Nginx configuration as well.

If your server supports systemd, you may wish to install the systemd script located in `systemd/homebus-ctrlh-access.service`. Copy it to `/etc/systemd/system` and run:
```
sudo systemctl daemon-reload
sudo systemctl enable homebus-ctrlh-access
sudo systemctl start homebus-ctrlh-access
```

You'll need to edit the file if you don't install `homebus-ctrlh-access` in the location expected in the file.

5. Configure nginx
```
sudo cp nginx/access-webhook.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/access-webhook.conf /etc/nginx/sites-enabled/access-webhook.conf
sudo systemctl reload nginx
```

6. Test

Open or unlock a door and watch for new entries in the Homebus recorder.

## LICENSE

This code is licensed under the [MIT License](https://romkey.mit-license.org).
