#!/bin/bash
#
# this script
# 0) sets gro,gso,lro,tso off
# 1) addp oisf ppa
# 2) installs suricata
# 3) sets suricata conf as amsterdam
# 4)


if [ "$(id -u)" != "0" ]; then
   echo "ERROR - This script must be run as root" 1>&2
   exit 1
fi

ETH=$1
SCIRIUS=$2

ethtool -K $ETH tx off sg off gro off gso off lro off tso off

#suricata
add-apt-repository -y ppa:oisf/suricata-stable 2>&1 > /dev/null
apt-get update 2>&1 > /dev/null
apt-get -y install suricata 2>&1 > /dev/null
service suricata stop
#stealing amsterdam suricata conf
wget -q https://raw.githubusercontent.com/StamusNetworks/Amsterdam/master/src/config/suricata/suricata.yaml -O /etc/suricata/suricata.yaml
wget -q https://raw.githubusercontent.com/StamusNetworks/Amsterdam/master/src/config/suricata/threshold.config -O /etc/suricata/threshold.config

#  - interface: eth0
sed -i -e 's,- interface: eth0,- interface: eth1,g' /etc/suricata/suricata.yaml
#fake scirius rules
#todo: get it from master
touch /etc/suricata/rules/scirius.rules
service suricata start
