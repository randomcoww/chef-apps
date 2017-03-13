#!/bin/bash
echo "install ZFS on Linux"

echo deb http://ftp.debian.org/debian stretch contrib >> /etc/apt/sources.list.d/contrib.list
apt-get -y update
apt-get -y install linux-headers-$(uname -r)
apt-get -y install zfs-dkms zfsutils-linux
