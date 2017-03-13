#!/bin/bash
echo "install Chef"

apt-get update -y
apt-get install -y --no-install-recommends wget ca-certificates
sh -c "wget -q -O - https://www.chef.io/chef/install.sh | bash"
apt-get clean

## mount chef secret from host
## copy this method: https://github.com/coreos/coreos-cloudinit/blob/master/units/90-configdrive.rules
cat > /lib/udev/rules.d/80-chef-secret-mount.rules <<EOF
ACTION!="add|change", GOTO="chef_secret_end"

SUBSYSTEM=="virtio", DRIVER=="9pnet_virtio", ATTR{mount_tag}=="chef-secret", TAG+="systemd", ENV{SYSTEMD_WANTS}+="etc-chef.mount"

LABEL="chef_secret_end"
EOF
