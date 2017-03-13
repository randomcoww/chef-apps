cat > /etc/systemd/system/chef-client.service <<EOF
[Unit]
Description=chef-client
After=etc-chef.mount

[Service]
TimeoutStartSec=0
Restart=on-failure
RestartSec=20
ExecStart=/usr/bin/chef-client -c /etc/chef/client.rb -i 600 -s 60 -o 'role[node-\$HOSTNAME]'

[Install]
WantedBy=multi-user.target
EOF
systemctl enable chef-client.service
