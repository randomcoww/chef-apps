node.default['environment_v2']['subnet']['lan'] = "192.168.62.0/23"
node.default['environment_v2']['subnet']['store'] = "192.168.126.0/23"
node.default['environment_v2']['subnet']['vpn'] = "192.168.30.0/23"
node.default['environment_v2']['subnet']['lan_dhcp_pool'] = "192.168.62.32/27"
node.default['environment_v2']['subnet']['vpn_dhcp_pool'] = "192.168.30.32/27"


node.default['environment_v2']['set']['gateway'] = {
  'hosts' => [
    'gateway1',
    'gateway2'
  ],
  'vip_lan' => "192.168.62.240"
}

node.default['environment_v2']['set']['gluster'] = {
  'hosts' => [
    'vm1',
    'vm2'
  ],
  'vip_lan' => "192.168.62.250",
  'vip_store' => "192.168.126.250"
}

node.default['environment_v2']['set']['dns'] = {
  'hosts' => [
    'dns1',
    'dns2'
  ],
  'vip_lan' => "192.168.62.230"
}

node.default['environment_v2']['set']['kea-mysql-mgmd'] = {
  'hosts' => [
    'kubelet1',
    'kubelet2'
  ]
}

node.default['environment_v2']['set']['kea-mysql'] = {
  'hosts' => [
    'kubelet1',
    'kubelet2'
  ]
}

node.default['environment_v2']['set']['etcd-flannel'] = {
  'hosts' => [
    'kubelet1',
    'kubelet2'
  ]
}

node.default['environment_v2']['set']['haproxy'] = {
  'hosts' => [
    'kube-node1',
    'kube-node2'
  ],
  'vip_lan' => "192.168.62.220"
}

node.default['environment_v2']['set']['etcd-kube'] = {
  'hosts' => [
    'kube-node1',
    'kube-node2'
  ]
}


##
## hosts
##

node.default['environment_v2']['host']['gateway1'] = {
  'ip_lan' => "192.168.62.241",
  'mac_wan' => "52:54:00:63:6e:b0",
  'if_lan' => 'eth0',
  'if_wan' => 'eth1',
}

node.default['environment_v2']['host']['gateway2'] = {
  'ip_lan' => "192.168.62.242",
  'mac_wan' => "52:54:00:63:6e:b1",
  'if_lan' => 'eth0',
  'if_wan' => 'eth1',
}

node.default['environment_v2']['host']['dns1'] = {
  'ip_lan' => "192.168.62.221",
  'if_lan' => 'eth0',
}

node.default['environment_v2']['host']['dns2'] = {
  'ip_lan' => "192.168.62.222",
  'if_lan' => 'eth0',
}

node.default['environment_v2']['host']['kubelet1'] = {
  'ip_lan' => "192.168.62.231",
  'if_lan' => 'eth0',
  'if_store' => 'eth1',
}

node.default['environment_v2']['host']['kubelet2'] = {
  'ip_lan' => "192.168.62.232",
  'if_lan' => 'eth0',
  'if_store' => 'eth1',
}

node.default['environment_v2']['host']['kube-node1'] = {
  'ip_lan' => "192.168.62.233",
  'ip_store' => "192.168.126.233",
  'if_lan' => 'eth0',
  'if_store' => 'eth1'
}

node.default['environment_v2']['host']['kube-node2'] = {
  'ip_lan' => "192.168.62.234",
  'ip_store' => "192.168.126.234",
  'if_lan' => 'eth0',
  'if_store' => 'eth1'
}


##
## one off
##

node.default['environment_v2']['host']['unifi1'] = {
  'ip_lan' => "192.168.62.217",
}

node.default['environment_v2']['host']['gamestream'] = {
  'ip_lan' => '192.168.63.99',
  'mac_lan' => '52:54:00:ac:da:f3'
}


##
## hardware
##

node.default['environment_v2']['host']['vm1'] = {
  'ip_lan' => '192.168.62.251',
  'ip_store' => '192.168.126.251',
  'if_lan' => 'host_lan',
  'if_store' => 'host_store',
  'vf_lan' => 'eno1',
  'vf_wan' => 'eno2',
  'vf_store' => 'ens1',
  # 'passthrough_hba' => {
  #   'domain' => "0x0000",
  #   'bus' => "0x01",
  #   'slot' => "0x00",
  #   'function' => "0x0",
  #   'file' => "/data/kvm/firmware/mptsas3.rom"
  # }
}

node.default['environment_v2']['host']['vm2'] = {
  'ip_lan' => '192.168.62.252',
  'ip_store' => '192.168.126.252',
  'if_lan' => 'host_lan',
  'if_store' => 'host_store',
  'vf_lan' => 'eno1',
  'vf_wan' => 'eno2',
  'vf_store' => 'ens1',
  # 'passthrough_hba' => {
  #   'domain' => "0x0000",
  #   'bus' => "0x01",
  #   'slot' => "0x00",
  #   'function' => "0x0",
  #   'file' => "/data/kvm/firmware/mptsas3.rom"
  # }
}

node.default['environment_v2']['host']['vm1-ipmi'] = {
  'ip_lan' => '192.168.63.61'
}

node.default['environment_v2']['host']['vm2-ipmi'] = {
  'ip_lan' => '192.168.63.62'
}

node.default['environment_v2']['host']['sw'] = {
  'ip_lan' => '192.168.63.95'
}


## load current host under 'current_host'
node.default['environment_v2']['current_host'] = node['environment_v2']['host'][node['hostname']]
