#!/bin/bash
echo "install ZFS on Linux"

echo deb http://ftp.debian.org/debian jessie-backports main contrib >> /etc/apt/sources.list.d/contrib.list
apt-get -y update
apt-get -y install linux-headers-$(uname -r)
apt-get -y install -t jessie-backports zfs-dkms zfsutils-linux
