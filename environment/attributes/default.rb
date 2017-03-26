node.default['environment']['lan_if'] = "eth0"
node.default['environment']['lan_vip_gateway'] = "192.168.62.240"
node.default['environment']['lan_subnet'] = "192.168.62.0/23"
node.default['environment']['lan_subnet_dhcp'] = "192.168.62.32/27"
node.default['environment']['lan_vrrp_id'] = 20

node.default['environment']['vpn_if'] = "brvpn"
node.default['environment']['vpn_subnet'] = "192.168.30.0/23"
node.default['environment']['vpn_subnet_dhcp'] = "192.168.30.32/27"

node.default['environment']['wan_if'] = "eth2"

node.default['environment']['dns_if'] = "eth0"
node.default['environment']['dns_vip'] = "192.168.62.250"
node.default['environment']['dns_ha_id'] = 21

node.default['environment']['lb_if'] = "eth0"
node.default['environment']['lb_vip'] = "192.168.62.230"
node.default['environment']['lb_ha_id'] = 22

node.default['environment']['gateway_ip'] = "192.168.62.242/23"

node.default['environment']['host_lan_if'] = 'eno1'
node.default['environment']['host_vpn_if'] = 'vpn'
node.default['environment']['host_wan_if'] = 'wan'
node.default['environment']['host_storage_if'] = 'enp7s0'

node.default['environment']['gluster_ip'] = '169.254.127.31/16'
