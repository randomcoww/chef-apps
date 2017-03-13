cat > /etc/systemd/system/var-lib-cloud-seed-nocloud\\x2dnet.mount <<EOF
[Unit]
Description=Mount cloud-init local directory
Before=cloud-init-local.service

[Mount]
What=cloud-init
Where=/var/lib/cloud/seed/nocloud-net
Type=9p
Options=ro,relatime,sync,dirsync,trans=virtio,version=9p2000.L
EOF
