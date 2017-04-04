node.default['environment_resource']['subnet'] = '192.168.62.0/23'
node.default['environment_resource']['data_bag'] = 'environment_resource'
node.default['environment_resource']['data_bag_item'] = 'v1'

node.default['environment_resource']['lan_dhcp_pool'] = ["192.168.62.32/27", "192.168.62.64/27"]
node.default['environment_resource']['vpn_dhcp_pool'] = ["192.168.30.32/27", "192.168.30.64/27"]

# node.default['environment_v2']['host_lan_if'] = 'eno1'
# node.default['environment_v2']['host_vpn_if'] = 'vpn'
# node.default['environment_v2']['host_wan_if'] = 'wan'
# node.default['environment_v2']['host_store_if'] = 'enp7s0'
# node.default['environment_v2']['host_wan_mac'] = '52:54:00:63:6e:b1'

node.default['environment_resource']['gateway_lan_ip'] = ["192.168.62.241", "192.168.62.242"]
node.default['environment_resource']['lb_lan_ip'] = ["192.168.62.231", "192.168.62.232"]
node.default['environment_resource']['gluster_lan_ip'] = ["192.168.62.251", "192.168.62.252"]
node.default['environment_resource']['gluster_store_ip'] = ["169.254.127.251", "169.254.127.252"]
