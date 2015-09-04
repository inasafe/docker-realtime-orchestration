#!/bin/sh
if [ $# -ne 2 ]
then 
	echo 'How to user:'
	echo 'setup-apt-cache.sh [interface_name] [foldername]'
fi

IP_ADDRESS=$(/sbin/ifconfig $1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

echo "IP address : $IP_ADDRESS"

if [ $# -eq 2 ]
then
	echo "Acquire::http { Proxy \"http://$IP_ADDRESS:3142\"; };" > "$2/71-apt-cacher-ng"
fi

if [ $# -eq 1 ]
then
	echo "Acquire::http { Proxy \"http://$IP_ADDRESS:3142\"; };" > "docker-apache/71-apt-cacher-ng"
	echo "Acquire::http { Proxy \"http://$IP_ADDRESS:3142\"; };" > "docker-inasafe/71-apt-cacher-ng"
	echo "Acquire::http { Proxy \"http://$IP_ADDRESS:3142\"; };" > "docker-sftp/71-apt-cacher-ng"
fi
