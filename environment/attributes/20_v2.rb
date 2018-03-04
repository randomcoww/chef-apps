node.default['environment_v2']['subnet']['lan'] = "192.168.62.0/23"
node.default['environment_v2']['subnet']['store'] = "192.168.126.0/23"
node.default['environment_v2']['subnet']['zfssync'] = "10.255.255.0/29"

node.default['environment_v2']['netmask']['lan'] = '255.255.254.0'
node.default['environment_v2']['netmask']['store'] = '255.255.254.0'
node.default['environment_v2']['netmask']['zfssync'] = '255.255.255.240'

node.default['environment_v2']['dhcp_pool']['lan'] = "192.168.62.64/26"
node.default['environment_v2']['dhcp_pool']['store'] = "192.168.126.64/26"

node.default['environment_v2']['domain']['rev'] = '168.192.in-addr.arpa'
node.default['environment_v2']['domain']['top'] = 'internal'
node.default['environment_v2']['domain']['vip'] = 'svc'
node.default['environment_v2']['domain']['host'] = 'host'


##
## sets
##

node.default['environment_v2']['set']['gateway'] = {
  'hosts' => [
    'gateway1',
    'gateway2'
  ],
  'vip' => {
    'store' => "192.168.126.240",
    'lan' => "192.168.62.240",
  }
}

node.default['environment_v2']['set']['dns'] = {
  'hosts' => [
    'ns1',
    'ns2',
    'ns3',
  ],
  'vip' => {
    'store' => "192.168.126.244",
    'lan' => "192.168.62.244",
  }
}

node.default['environment_v2']['set']['kea'] = {
  'hosts' => [
    'ns1',
    'ns2'
  ],
  'vip' => {
    'store' => "192.168.126.245",
  }
}

node.default['environment_v2']['set']['kea-mysql-data'] = {
  'hosts' => [
    'ns1',
    'ns2'
  ]
}

node.default['environment_v2']['set']['kea-mysql-mgm'] = {
  'hosts' => [
    'ns3',
  ]
}

node.default['environment_v2']['set']['pxe'] = {
  'hosts' => [
    'ns1',
    'ns2',
  ],
  'vip' => {
    'store' => "192.168.126.246",
  }
}

node.default['environment_v2']['set']['etcd'] = {
  'hosts' => [
    'vm1',
  ],
  # 'hosts' => [
  #   'etcd1',
  #   'etcd2',
  #   'etcd3',
  # ],
  # "services" => {
  #   'etcd-server-ssl' => {
  #     "port" => 2380,
  #     "proto" => "tcp",
  #   },
  #   'etcd-client-ssl' => {
  #     "port" => 2379,
  #     "proto" => "tcp"
  #   }
  # }
}

node.default['environment_v2']['set']['haproxy'] = {
  'hosts' => [
    'vm1',
    'kube-master',
  ],
  'vip' => {
    'store' => "192.168.126.242",
  }
}

node.default['environment_v2']['set']['kube-master'] = {
  'hosts' => [
    'vm1',
    'kube-master',
  ],
  'services' => {
    'kube-master' => {
      "port" => 62442,
      "proto" => "tcp"
    }
  }
}

node.default['environment_v2']['set']['kube-worker'] = {
  'hosts' => [
    'kube-worker'
  ]
}

node.default['environment_v2']['set']['vmhost'] = {
  'hosts' => [
    'vm1',
    'vm2',
  ]
}

node.default['environment_v2']['set']['mgm'] = {
  'hosts' => [
    'chromebook',
  ]
}


##
## hosts
##

node.default['environment_v2']['host']['gateway1'] = {
  'ip' => {
    'store' => "192.168.126.217",
    'lan' => "192.168.62.217",
  },
  'if' => {
    # 'lan' => "ens2",
    # 'store' => "ens3",
    # 'wan' => "ens4",
    'lan' => "eth0",
    'store' => "eth1",
    'wan' => "eth2",
  },
  'mac' => {
    "wan" => "52:54:00:63:6e:b0"
  },
  'if_type' => {
    'lan' => 'macvlan',
    'store' => 'macvlan',
    'wan' => 'macvlan',
  },
  'memory' => 6144,
  'vcpu' => 2,
}

node.default['environment_v2']['host']['gateway2'] = {
  'ip' => {
    'store' => "192.168.126.218",
    'lan' => "192.168.62.218",
  },
  'if' => {
    # 'lan' => "ens2",
    # 'store' => "ens3",
    # 'wan' => "ens4",
    'lan' => "eth0",
    'store' => "eth1",
    'wan' => "eth2",
  },
  'mac' => {
    "wan" => "52:54:00:63:6e:b1"
  },
  'if_type' => {
    'lan' => 'macvlan',
    'store' => 'macvlan',
    'wan' => 'macvlan',
  },
  'memory' => 6144,
  'vcpu' => 2
}

node.default['environment_v2']['host']['ns1'] = {
  'ip' => {
    'store' => "192.168.126.219",
    'lan' => "192.168.62.219",
  },
  'gw' => {
    'store' => node['environment_v2']['set']['gateway']['vip']['store'],
    'lan' => node['environment_v2']['set']['gateway']['vip']['lan'],
  },
  'if' => {
    'lan' => "eth0",
    'store' => "eth1",
  },
  'if_type' => {
    'lan' => 'macvlan',
    'store' => 'macvlan',
  },
  'memory' => 6144,
  'vcpu' => 2,
}

node.default['environment_v2']['host']['ns2'] = {
  'ip' => {
    'store' => "192.168.126.220",
    'lan' => "192.168.62.220",
  },
  'gw' => {
    'store' => node['environment_v2']['set']['gateway']['vip']['store'],
    'lan' => node['environment_v2']['set']['gateway']['vip']['lan'],
  },
  'if' => {
    'lan' => "eth0",
    'store' => "eth1",
  },
  'if_type' => {
    'lan' => 'macvlan',
    'store' => 'macvlan',
  },
  'memory' => 6144,
  'vcpu' => 2,
}

node.default['environment_v2']['host']['ns3'] = {
  'ip' => {
    'store' => "192.168.126.221",
    'lan' => "192.168.62.221",
  },
  'gw' => {
    'store' => node['environment_v2']['set']['gateway']['vip']['store'],
    'lan' => node['environment_v2']['set']['gateway']['vip']['lan'],
  },
  'if' => {
    'lan' => "eth0",
    'store' => "eth1",
  },
  'if_type' => {
    'lan' => 'macvlan',
    'store' => 'macvlan',
  },
  'memory' => 6144,
  'vcpu' => 2,
}

node.default['environment_v2']['host']['etcd1'] = {
  'ip' => {
    'store' => "192.168.126.222",
  },
  'gw' => {
    'store' => node['environment_v2']['set']['gateway']['vip']['store'],
  },
  'if' => {
    'store' => "eth0",
  },
  'if_type' => {
    'store' => 'macvlan',
  },
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['etcd2'] = {
  'ip' => {
    'store' => "192.168.126.223",
  },
  'gw' => {
    'store' => node['environment_v2']['set']['gateway']['vip']['store'],
  },
  'if' => {
    'store' => "eth0",
  },
  'if_type' => {
    'store' => 'macvlan',
  },
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['etcd3'] = {
  'ip' => {
    'store' => "192.168.126.224",
  },
  'gw' => {
    'store' => node['environment_v2']['set']['gateway']['vip']['store'],
  },
  'if' => {
    'store' => "eth0",
  },
  'if_type' => {
    'store' => 'macvlan',
  },
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['kube-master'] = {
  'if' => {
    'store' => "eth0",
  },
  'if_type' => {
    'store' => 'macvlan',
  },
  'memory' => 6144,
  'vcpu' => 4
}

node.default['environment_v2']['host']['kube-worker'] = {
  'if' => {
    'store' => "eth0",
  },
  'if_type' => {
    'store' => 'macvlan',
  },
  'memory' => 6144,
  'vcpu' => 4
}

##
## hardware
##

node.default['environment_v2']['host']['vm1'] = {
  'ip' => {
    'store' => '192.168.126.251',
    'zfssync' => '10.255.255.1'
  },
  'if' => {
    'lan' => "eno2",
    'wan' => "wan",
    'store' => "eno1",
    'zfssync' => "ens1f0"
  },
  # 'passthrough_hba' => {
  #   'domain' => "0x0000",
  #   'bus' => "0x01",
  #   'slot' => "0x00",
  #   'function' => "0x0",
  #   'file' => "/data/kvm/firmware/mptsas3.rom"
  # }
  'guests' => [
    'gateway1',
    'gateway2',
    'ns1',
    'ns2',
    'ns3',
    'etcd1',
    'etcd2',
    'etcd3',
    'kube-master',
    'kube-worker'
  ]
}

node.default['environment_v2']['host']['vm2'] = {
  'ip' => {
    'store' => '192.168.126.252',
    'zfssync' => '10.255.255.2'
  },
  'if' => {
    'lan' => "eno2",
    'wan' => "wan",
    'store' => "eno1",
    'zfssync' => "ens1f0"
  },
  # 'passthrough_hba' => {
  #   'domain' => "0x0000",
  #   'bus' => "0x01",
  #   'slot' => "0x00",
  #   'function' => "0x0",
  #   'file' => "/data/kvm/firmware/mptsas3.rom"
  # }
  'guests' => [
    # 'gateway1',
    # 'gateway2',
  ]
}

node.default['environment_v2']['host']['vm1-ipmi'] = {
  'ip' => {
    'lan' => '192.168.127.61'
  }
}

node.default['environment_v2']['host']['vm2-ipmi'] = {
  'ip' => {
    'lan' => '192.168.127.62'
  }
}

node.default['environment_v2']['host']['sw'] = {
  'ip' => {
    'lan' => '192.168.127.95'
  }
}

node.default['environment_v2']['host']['chromebook'] = {
  'ip' => {
    'store' => '192.168.127.96',
  },
  'if' => {
    'store' => "enp4s0",
  },
}

##
## aliases
##

node.default['environment_v2']['set']['nfs'] = {
  'vip' => {
    'store' => node['environment_v2']['host']['vm1']['ip']['store'],
  }
}

node.default['environment_v2']['set']['transmission'] = {
  'vip' => {
    'store' => node['environment_v2']['set']['haproxy']['vip']['store']
  }
}

node.default['environment_v2']['host']['unifi'] = {
  'ip' => {
    'lan' => node['environment_v2']['set']['haproxy']['vip']['store']
  }
}
