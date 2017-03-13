#!/bin/sh

echo vm.swappiness = 0 >> /etc/sysctl.conf
apt-get -y install ntp vim
