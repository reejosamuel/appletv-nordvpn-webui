#!/bin/bash

helpFunction()
{
   echo ""``
   echo "Usage: $0 -c [country code] -r [1 or 0]-i [IP address]"
   echo -e "\t-c 2 Letter country code. e.g. CA, US, UK"
   echo -e "\t-r if it is a reconnection"
   echo -e "\t-i source ip addresses as a string array"

   exit 1 # Exit script after printing help
}

while getopts "i:c:r:" opt
do
   case "$opt" in
      i ) parameterIP="$OPTARG" ;;
      c ) parameterC="$OPTARG" ;;
      r ) parameterR="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterIP" ] || [ -z "$parameterC" ] || [ -z "$parameterR" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct
echo "Connecting to $parameterC VPN"

nordvpn connect $parameterC
# connect_output=`nordvpn connect $parameterC`
# echo "nord $connect_output"

if [[ "$parameterR" -eq 1 ]]
then
    exit 0
fi

sudo iptables -t nat -A POSTROUTING -o nordlynx -j MASQUERADE
sudo iptables -A FORWARD -i nordlynx -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

IFS=';' read -ra my_array <<< "$parameterIP"
for i in ${my_array[@]}
do
    echo "configuring iptables for $i"
    sudo iptables -A FORWARD -i eth0 -o nordlynx -s $i/32 -j ACCEPT
    sudo iptables -t nat -A PREROUTING -s $i/32 -p udp -m udp --dport 53 -j DNAT --to-destination 103.86.96.100:53
    sudo iptables -t nat -A PREROUTING -s $i/32 -p tcp -m tcp --dport 53 -j DNAT --to-destination 103.86.96.100:53
    echo "moving to configure next ip"
done

