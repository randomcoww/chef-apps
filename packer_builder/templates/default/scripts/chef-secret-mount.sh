cat > /etc/systemd/system/etc-chef.mount <<EOF
[Unit]
Description=Mount Chef secret
Before=chef-client.service

[Mount]
What=chef-secret
Where=/etc/chef
Type=9p
Options=ro,relatime,sync,dirsync,trans=virtio,version=9p2000.L
EOF
