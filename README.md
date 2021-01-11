### Scrappy Nord VPN Web UI

Quick hacky solution to route all the traffic from Apple TV to Nord VPN running inside a raspberry pi (or any linux distro) on the same network. This routes all the DNS (udp+tcp) queries and traffic to nordvpn when enabled. A tiny web-ui to toggle and select vpn country to go along with it. 

When VPN is turned off this simply routes traffic to the internet. 

All the `iptables` routes are in the `connect.sh` and `reset.sh`

It was first setup to work with google assistant but that turned out to be less fun since you can directly third party services on google assistant without first voice opening the app.

#### Install

Install the nord vpn app for linux first

Set the technology to Nord Lynx (for speed)

Login (`nordvpn login`)

# Fix the source IP 

Edit the below file and change to the IP of the source device (in my case the apple-tvs). Recommeded giving these devices static ip and forgetting dhcp to avoid having  to edit this file frequently.

file: `commands.rb`

``` ruby
    CLIENTS = [
        "192.168.1.2",
        "192.168.1.3"
    ]
```

Copy service file to start on boot

        sudo cp ./vpn-webui.service /lib/systemd/system/
        sudo systemctl start vpn-webui
        sudo systemctl enable vpn-webui

Adjust the location of the repo in the service script if not home directory

Tail service logs for debugging

        sudo journalctl -u vpn-webui -n 20 -f

Starting server for local development 

        ruby main.rb


#### Finally

Set the **gateway** and **DNS** on the AppleTV to IP address of the pi

### Access the UI 

Access the web-ui by going to <IP_Address:4567> (default sinatra port)