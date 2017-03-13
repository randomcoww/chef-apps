#!/bin/sh
echo "enable systemd networking"

systemctl disable networking
systemctl reset-failed

cat > /etc/systemd/resolved.conf <<EOF
[Resolve]
FallbackDNS=
DNSStubListener=no
EOF

systemctl enable systemd-networkd
systemctl enable systemd-resolved
chattr -i /etc/resolv.conf
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

## something else still keeps starting dhclient on interfaces defined in /etc/network/interfaces.
## deleting the interfaces file seems to prevent this.
rm /etc/network/interfaces
