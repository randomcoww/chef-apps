node.default['environment_v2']['subnet']['lan'] = "192.168.62.0/23"
node.default['environment_v2']['subnet']['store'] = "169.254.0.0/16"
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
    'gluster1',
    'gluster2'
  ],
  'vip_lan' => "192.168.62.250",
  'vip_store' => "169.254.127.250"
}

node.default['environment_v2']['set']['dns'] = {
  'hosts' => [
    'dns1',
    'dns2'
  ],
  'vip_lan' => "192.168.62.230"
}

node.default['environment_v2']['set']['mysql-mgm'] = {
  'hosts' => [
    'mysql-mgm'
  ]
}

node.default['environment_v2']['set']['mysql-ndb'] = {
  'hosts' => [
    'mysql-ndb1',
    'mysql-ndb2'
  ]
}

node.default['environment_v2']['set']['haproxy'] = {
  'hosts' => [
    'haproxy1',
    'haproxy2'
  ],
  'vip_lan' => "192.168.62.220"
}

node.default['environment_v2']['set']['etcd'] = {
  'hosts' => [
    'kube-master1',
    'kube-master2',
    'kube-master3'
  ]
}

node.default['environment_v2']['set']['kube-master'] = {
  'hosts' => [
    'kube-master1',
    'kube-master2',
    'kube-master3'
  ]
}

node.default['environment_v2']['set']['kube-worker'] = {
  'hosts' => [
    'kube-worker1',
    'kube-worker2'
  ]
}


## hardware override
node.default['environment_v2']['host']['vm1'] = {
  'ip_lan' => '192.168.63.30',
  'if_lan' => 'eno1',
  'if_vpn' => 'vpn',
  'if_wan' => 'wan',
  'if_store' => 'enp5s0',
  'passthrough_hba' => {
    'domain' => "0x0000",
    'bus' => "0x03",
    'slot' => "0x00",
    'function' => "0x0",
    'file' => "/img/kvm/firmware/mptsas2.rom"
  }
}

node.default['environment_v2']['host']['vm2'] = {
  'ip_lan' => '192.168.63.31',
  'if_lan' => 'eno1',
  'if_vpn' => 'vpn',
  'if_wan' => 'wan',
  'if_store' => 'enp7s0',
  'passthrough_hba' => {
    'domain' => "0x0000",
    'bus' => "0x03",
    'slot' => "0x00",
    'function' => "0x0",
    'file' => "/img/kvm/firmware/mptsas3.rom"
  }
}

node.default['environment_v2']['host']['gateway1'] = {
  'ip_lan' => "192.168.62.241",
  'mac_wan' => "52:54:00:63:6e:b0"
}

node.default['environment_v2']['host']['gateway2'] = {
  'ip_lan' => "192.168.62.242",
  'mac_wan' => "52:54:00:63:6e:b1"
}

node.default['environment_v2']['host']['gluster1'] = {
  'ip_lan' => "192.168.62.251",
  'ip_store' => "169.254.127.251"
}

node.default['environment_v2']['host']['gluster2'] = {
  'ip_lan' => "192.168.62.252",
  'ip_store' => "169.254.127.252"
}

node.default['environment_v2']['host']['dns1'] = {
  'ip_lan' => "192.168.62.231"
}

node.default['environment_v2']['host']['dns2'] = {
  'ip_lan' => "192.168.62.232"
}

node.default['environment_v2']['host']['mysql-mgm'] = {
  'ip_lan' => "192.168.62.211"
}

node.default['environment_v2']['host']['mysql-ndb1'] = {
  'ip_lan' => "192.168.62.213"
}

node.default['environment_v2']['host']['mysql-ndb2'] = {
  'ip_lan' => "192.168.62.214"
}

node.default['environment_v2']['host']['haproxy1'] = {
  'ip_lan' => "192.168.62.221"
}

node.default['environment_v2']['host']['haproxy2'] = {
  'ip_lan' => "192.168.62.222"
}

node.default['environment_v2']['host']['kube-master1'] = {
  'ip_lan' => "192.168.62.201"
}

node.default['environment_v2']['host']['kube-master2'] = {
  'ip_lan' => "192.168.62.202"
}

node.default['environment_v2']['host']['kube-master3'] = {
  'ip_lan' => "192.168.62.205"
}

node.default['environment_v2']['host']['kube-worker1'] = {
  'ip_lan' => "192.168.62.203"
}

node.default['environment_v2']['host']['kube-worker2'] = {
  'ip_lan' => "192.168.62.204"
}

node.default['environment_v2']['host']['test1'] = {
  'ip_lan' => "192.168.62.239"
}

node.default['environment_v2']['host']['vm1-ipmi'] = {
  'ip_lan' => '192.168.63.64'
}

node.default['environment_v2']['host']['vm2-ipmi'] = {
  'ip_lan' => '192.168.63.63'
}

# node.default['environment_v2']['host']['sw'] = {
#   'ip_lan' => '192.168.63.95'
# }

node.default['environment_v2']['host']['gamestream'] = {
  'ip_lan' => '192.168.63.99',
  'mac_lan' => '52:54:00:ac:da:f3'
}


## load current host under 'current_host'
node.default['environment_v2']['current_host'] = node['environment_v2']['host'][node['hostname']]
