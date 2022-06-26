#!/bin/bash

INTF=$1
IPADDR=$2
GW=$3
DNS=$4

#Check if static config is required
if [ -z $INTF ]; then
	echo "no static config supplied"
	exit
fi

#Make a copy of netplan config format
sudo cp /home/pocuser/50-netcfg.yaml.in /home/pocuser/50-netcfg.yaml

#Populate interface, ipaddr, gateway and dns server
#e.g. ens3, 192.168.1.11/24, 192.168.1.1 and 192.168.1.1
sudo sed -e 's,INTERFACE,'$INTF',g' -i  /home/pocuser/50-netcfg.yaml
sudo sed -e 's,IPADDRWITHMASK,'$IPADDR',g' -i /home/pocuser/50-netcfg.yaml 
sudo sed -e 's,GATEWAY,'$GW',g' -i /home/pocuser/50-netcfg.yaml
sudo sed -e 's,DNSSERVER,'$DNS',g' -i /home/pocuser/50-netcfg.yaml

#copy generated config file to netplan config directory
sudo cp /home/pocuser/50-netcfg.yaml /etc/netplan/50-cloud-init.yaml
sudo netplan apply
