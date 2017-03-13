#!/bin/bash
echo "install unifi"

apt-get -y install apt-transport-https ca-certificates gnupg2 dirmngr
apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50
echo deb http://www.ubnt.com/downloads/unifi/debian unifi5 ubiquiti > /etc/apt/sources.list.d/100-ubnt.list
apt-get -y update
apt-get -y install --no-install-recommends unifi

## mongo is launched separately by unifi. don't let it come up with default configs
systemctl disable mongodb
