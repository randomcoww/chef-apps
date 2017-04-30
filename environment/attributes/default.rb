## hardware override
node.default['environment_v2']['vm1']['host_lan_if'] = "eno1"
node.default['environment_v2']['vm1']['host_vpn_if'] = "vpn"
node.default['environment_v2']['vm1']['host_wan_if'] = "wan"
node.default['environment_v2']['vm1']['host_store_if'] = "enp5s0"

node.default['environment_v2']['vm1']['hba_source'] = {
  'domain' => "0x0000",
  'bus' => "0x03",
  'slot' => "0x00",
  'function' => "0x0",
  'file' => "/img/kvm/firmware/mptsas2.rom"
}

node.default['environment_v2']['vm2']['host_lan_if'] = "eno1"
node.default['environment_v2']['vm2']['host_vpn_if'] = "vpn"
node.default['environment_v2']['vm2']['host_wan_if'] = "wan"
node.default['environment_v2']['vm2']['host_store_if'] = "enp7s0"

node.default['environment_v2']['vm2']['hba_source'] = {
  'domain' => "0x0000",
  'bus' => "0x03",
  'slot' => "0x00",
  'function' => "0x0",
  'file' => "/img/kvm/firmware/mptsas3.rom"
}


## common
node.default['environment_v2']['ssh_authorized_keys'] = [
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCf4YDpCaridIv8B4LIj8zYVbRfEgDvstlFu4nllhfY9UEcoHgBHEDmCFe1+qsv3flxTm7Q5v4q6RIETS2AwzRTlSTyzcI6t8jQ16R6aoLcbU2J2kWsD/rGHAuHGtZb2950rApIfOdP4n05uW34We6ErZmlCC0R/x9JIP5QqvoJE9KaVC3v/vPG1KVsYZFxtyKVHnFwwPlzjtHp+Tq0xG7jCPG5w+fekpvcImxo8isunRkpyHQFRE0nQAlIfCmJ1LdG3PREswuinKHiW33hXqkRVCSXmF2PGLW+x9aWvcMgbguX9WGWO4Dafta2lzwN6x4QWmc6bQpO1akw3Qi5rzQN'
]

node.default['environment_v2']['gateway_lan_vip'] = "192.168.62.240"
node.default['environment_v2']['dns_lan_vip'] = "192.168.62.230"
node.default['environment_v2']['cql_lan_vip'] = "192.168.62.220"
node.default['environment_v2']['gluster_lan_vip'] = "192.168.62.250"
node.default['environment_v2']['gluster_store_vip'] = "169.254.127.250"
node.default['environment_v2']['mysql_lan_vip'] = "192.168.62.210"

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

node.default['environment_v2']['dns1_lan_ip'] = "192.168.62.231"
node.default['environment_v2']['dns2_lan_ip'] = "192.168.62.232"

node.default['environment_v2']['mysql1_lan_ip'] = "192.168.62.211"
node.default['environment_v2']['mysql2_lan_ip'] = "192.168.62.212"

node.default['environment_v2']['dhcp1_lan_ip'] = "192.168.62.221"
node.default['environment_v2']['dhcp2_lan_ip'] = "192.168.62.222"
node.default['environment_v2']['dhcp3_lan_ip'] = "192.168.62.223"
node.default['environment_v2']['dhcp4_lan_ip'] = "192.168.62.224"

node.default['environment_v2']['dhcp1_vpn_ip'] = "192.168.30.221"
node.default['environment_v2']['dhcp2_vpn_ip'] = "192.168.30.222"
node.default['environment_v2']['dhcp3_vpn_ip'] = "192.168.30.223"
node.default['environment_v2']['dhcp4_vpn_ip'] = "192.168.30.224"

node.default['environment_v2']['lan_dhcp_pool1'] = "192.168.62.32/27"
node.default['environment_v2']['lan_dhcp_pool2'] = "192.168.62.64/27"
node.default['environment_v2']['vpn_dhcp_pool1'] = "192.168.30.32/27"
node.default['environment_v2']['vpn_dhcp_pool2'] = "192.168.30.64/27"

node.default['environment_v2']['lan_dhcp_pool'] = "192.168.62.32/27"
node.default['environment_v2']['vpn_dhcp_pool'] = "192.168.30.32/27"

##
if !node['environment_v2'][node['hostname']].nil?
  node['environment_v2'][node['hostname']].each do |k, v|
    node.default['environment_v2'][k] = v
  end
end
