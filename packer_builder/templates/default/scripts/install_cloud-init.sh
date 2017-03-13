#!/bin/sh
echo "install cloud-init"

apt-get update -y
apt-get -y install cloud-init net-tools
apt-get clean
mkdir -p /var/lib/cloud/seed/nocloud-net

## copy this method: https://github.com/coreos/coreos-cloudinit/blob/master/units/90-configdrive.rules
cat > /lib/udev/rules.d/10-cloud-init-mount.rules <<EOF
ACTION!="add|change", GOTO="cloud_init_end"

SUBSYSTEM=="virtio", DRIVER=="9pnet_virtio", ATTR{mount_tag}=="cloud-init", TAG+="systemd", ENV{SYSTEMD_WANTS}+="var-lib-cloud-seed-nocloud\x2dnet.mount"

LABEL="cloud_init_end"
EOF
