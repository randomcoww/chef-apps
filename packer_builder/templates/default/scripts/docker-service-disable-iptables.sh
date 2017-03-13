mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/10-disable-iptables.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// --iptables=false
EOF
systemctl daemon-reload
