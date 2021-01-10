#!/bin/bash

nordvpn disconnect
if [ $? -eq 0 ]; then
    echo "OK"
else
	echo "Checking for nodvpn deamon to kill"
	nord_pid=$(pgrep -f nordvpnd)
	if [ -n "$nord_pid" ]; then
		echo "Force killing Nord VPN"
	    sudo kill -9 $nord_pid
    fi
fi

echo "Resetting IP tables"

sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X

