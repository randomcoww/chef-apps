#!/bin/sh
echo "blacklist iptables modules"

echo install iptable_nat /bin/false >> /etc/modprobe.d/iptable_blacklist.conf
echo install iptable_filter /bin/false >> /etc/modprobe.d/iptable_blacklist.conf
