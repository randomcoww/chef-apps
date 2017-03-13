#!/bin/sh
echo "sysctl options"

echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
echo net.ipv4.ip_nonlocal_bind = 1 >> /etc/sysctl.conf
