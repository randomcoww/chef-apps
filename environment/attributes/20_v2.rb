node.default['environment_v2']['ssh_authorized_keys']['default'] = [
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC48pu0Cl9VJ5p40Fqb/HU2FH6W4WlxG3N4R+SikofgzhhUI1yy/nrKziunFy+82kOA1RYKnlqQfv3cOoeSt0I+Qe622UmKsJEmmOo/ynEdzb22BnLIW+t+OFDCGs9NP1vIhnBPl7rxuw1U8w+0BZf7aJ5ateNhWh/7S6ACmpiIqtPAyKSGlel1sir3zDrSL21Ds9mUNRGhaQhVwNxr/q82C1DAYRnCNr04+BWh3BnY6kREWVfbr+FvpdCSN8Z42pfWByc3ZkQZYSJPBGBhRxPc3l08WwE663pFAaQTCq1wyaWplK5FLnl8ZrnfjU0Ej87iTiN8LG46UpPOjMRqH8uN',
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDV32iY0Sg4ZrLBg8MzUGtwteIJn4CpqxRLCRv/ayGBIbv8yRD0zR5K8mT2lh9NjST0g84W8x8MZswnurTzD/a9FyQzD9nOGCpe+PMFlOPg9oArZO0GOa74j36aRKdMou+/URi37EMc5caQPGbKzez7ylj4LKsznoeRQuIGDFE1kwatTXvH9alb/lp1jX97fcesEVc0r28MEU70lmfc9tdkF3+9gpzztDrrg0zdsuE8l9LtnbMK+SVbXASjLbkYDjBn6qP8zmv1gFOLz09N+/0C6Jsqzmxxa5KW5f6DfnYv1i3Ov+1lbN8L7709/qcVZs6kG9jsuYiyAjrsouu7jlNj'
]

node.default['environment_v2']['subnet']['lan'] = "192.168.62.0/23"
node.default['environment_v2']['subnet']['store'] = "192.168.126.0/23"
node.default['environment_v2']['subnet']['lan_dhcp_pool'] = "192.168.62.32/27"
node.default['environment_v2']['subnet']['store_dhcp_pool'] = "192.168.126.32/27"

node.default['environment_v2']['domain']['top'] = 'lan'
node.default['environment_v2']['domain']['host_lan'] = 'hl'
node.default['environment_v2']['domain']['vip_lan'] = 'vl'
node.default['environment_v2']['domain']['host_store'] = 'hs'
node.default['environment_v2']['domain']['vip_store'] = 'vs'


##
## sets
##

node.default['environment_v2']['set']['gateway'] = {
  'hosts' => [
    'coreos-gateway1',
    'coreos-gateway2'
  ],
  'vip_lan' => "192.168.62.240"
}

node.default['environment_v2']['set']['haproxy'] = {
  'hosts' => [
    'coreos-gateway1',
    'coreos-gateway2'
  ],
  'vip_lan' => "192.168.62.240"
}

node.default['environment_v2']['set']['dns'] = {
  'hosts' => [
    'coreos-gateway1',
    'coreos-gateway2'
  ]
}

node.default['environment_v2']['set']['kea'] = {
  'hosts' => [
    'coreos-gateway1',
    'coreos-gateway2'
  ]
}

node.default['environment_v2']['set']['kube-master'] = {
  'hosts' => [
    'coreos-kube-master1',
    'coreos-kube-master2'
  ]
}

node.default['environment_v2']['set']['kube-worker'] = {
  'hosts' => [
    'coreos-kube-worker1',
    'coreos-kube-worker2'
  ]
}

node.default['environment_v2']['set']['etcd'] = {
  'hosts' => [
    'coreos-etcd1',
    'coreos-etcd2',
    'coreos-etcd3'
  ]
}


##
## hosts
##

node.default['environment_v2']['host']['coreos-gateway1'] = {
  'ip_lan' => "192.168.62.217",
  'if_lan' => 'eth0',
  'if_wan' => 'eth1',
  'mac_wan' => "52:54:00:63:6e:b0",
  'memory' => 8192,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-gateway2'] = {
  'ip_lan' => "192.168.62.218",
  'if_lan' => 'eth0',
  'if_wan' => 'eth1',
  'mac_wan' => "52:54:00:63:6e:b1",
  'memory' => 8192,
  'vcpu' => 2
}


node.default['environment_v2']['host']['coreos-etcd1'] = {
  'if_lan' => 'eth0',
  'memory' => 4096,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-etcd2'] = {
  'if_lan' => 'eth0',
  'memory' => 4096,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-etcd3'] = {
  'if_lan' => 'eth0',
  'memory' => 4096,
  'vcpu' => 2
}


node.default['environment_v2']['host']['coreos-kube-master1'] = {
  'if_lan' => 'eth0',
  'memory' => 8192,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-kube-master2'] = {
  'if_lan' => 'eth0',
  'memory' => 8192,
  'vcpu' => 2
}


node.default['environment_v2']['host']['coreos-kube-worker1'] = {
  'if_lan' => 'eth0',
  'memory' => 8192,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-kube-worker2'] = {
  'if_lan' => 'eth0',
  'memory' => 8192,
  'vcpu' => 2
}


##
## one off
##

node.default['environment_v2']['host']['unifi'] = {
  'ip_lan' => "192.168.62.100",
}


##
## hardware
##

node.default['environment_v2']['host']['vm1'] = {
  'ip_lan' => '192.168.62.251',
  'ip_store' => '192.168.126.251',
  'if_lan' => 'host_lan',
  'if_wan' => 'host_wan',
  'if_store' => 'host_store',
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
  'if_wan' => 'host_wan',
  'if_store' => 'host_store',
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

node.default['environment_v2']['host']['chromebook'] = {
  'ip_lan' => '192.168.63.96'
}


## load current host under 'current_host'
node.default['environment_v2']['node_name'] = ENV['NODE_NAME']
node.default['environment_v2']['node_host'] = node['environment_v2']['host'][node['environment_v2']['node_name']]
