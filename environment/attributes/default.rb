## common
node.default['environment_v2']['gateway_lan_vip'] = "192.168.62.240"
node.default['environment_v2']['lb_lan_vip'] = "192.168.62.230"
node.default['environment_v2']['gluster_lan_vip'] = "192.168.62.250"
node.default['environment_v2']['gluster_store_vip'] = "169.254.127.250"

node.default['environment_v2']['lan_subnet'] = "192.168.62.0/23"
node.default['environment_v2']['store_subnet'] = "169.254.0.0/16"
node.default['environment_v2']['vpn_subnet'] = "192.168.30.0/23"

node.default['environment_v2']['gateway1_lan_ip'] = "192.168.62.241"
node.default['environment_v2']['gateway2_lan_ip'] = "192.168.62.242"
node.default['environment_v2']['gateway1_wan_mac'] = "52:54:00:63:6e:b0"
node.default['environment_v2']['gateway2_wan_mac'] = "52:54:00:63:6e:b1"

node.default['environment_v2']['gluster1_lan_ip'] = "192.168.62.251"
node.default['environment_v2']['gluster2_lan_ip'] = "192.168.62.252"
node.default['environment_v2']['gluster1_store_ip'] = "169.254.127.251"
node.default['environment_v2']['gluster2_store_ip'] = "169.254.127.252"

node.default['environment_v2']['lb1_lan_ip'] = "192.168.62.231"
node.default['environment_v2']['lb2_lan_ip'] = "192.168.62.232"

node.default['environment_v2']['lan_dhcp_pool1'] = "192.168.62.32/27"
node.default['environment_v2']['lan_dhcp_pool2'] = "192.168.62.64/27"
node.default['environment_v2']['vpn_dhcp_pool1'] = "192.168.30.32/27"
node.default['environment_v2']['vpn_dhcp_pool2'] = "192.168.30.64/27"
