#!/bin/bash

helpFunction()
{
   echo ""``
   echo "Usage: $0 -c [country code] -i [IP_ADDRESS1;IP_ADDRESS2]"
   echo -e "\t-c 2 Letter country code. e.g. CA, US, UK"
   echo -e "\t-i source ip addresses as a string array"

   exit 1 # Exit script after printing help
}

while getopts "i:c:" opt
do
   case "$opt" in
      i ) parameterIP="$OPTARG" ;;
      c ) parameterC="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterIP" ] || [ -z "$parameterC" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi


# Begin script in case all parameters are correct
echo "CONNECTING to $parameterC ...."


nordvpn connect $parameterC
if [ $? -eq 0 ]; then
    echo "CONNECTED TO $parameterC";
else
    echo "CONNECTION failed to $parameterC";
    exit 0;
fi


# check if the rule exists before to prevent adding them again
sudo iptables -C FORWARD -i nordlynx -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
if [ $? -eq 0 ]; then
    echo "IP Rules exist";
    exit 0;
fi

sudo iptables -t nat -A POSTROUTING -o nordlynx -j MASQUERADE
sudo iptables -A FORWARD -i nordlynx -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

IFS=';' read -ra my_array <<< "$parameterIP"
for i in ${my_array[@]}
do
    echo "ADDING IPTABLES FOR --> $i"
    sudo iptables -A FORWARD -i eth0 -o nordlynx -s $i/32 -j ACCEPT
    sudo iptables -t nat -A PREROUTING -s $i/32 -p udp -m udp --dport 53 -j DNAT --to-destination 103.86.96.100:53
    sudo iptables -t nat -A PREROUTING -s $i/32 -p tcp -m tcp --dport 53 -j DNAT --to-destination 103.86.96.100:53
    echo "CHECING LOOP FOR ADDITIONAL IPs TO ADD"
done

