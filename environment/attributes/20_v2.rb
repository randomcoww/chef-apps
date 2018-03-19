node.default['environment_v2']['subnet']['lan'] = "192.168.62.0/23"
node.default['environment_v2']['subnet']['store'] = "192.168.126.0/23"

node.default['environment_v2']['netmask']['lan'] = '255.255.254.0'
node.default['environment_v2']['netmask']['store'] = '255.255.254.0'

node.default['environment_v2']['dhcp_pool']['lan'] = "192.168.62.64/26"
node.default['environment_v2']['dhcp_pool']['store'] = "192.168.126.64/26"

node.default['environment_v2']['domain']['rev'] = '168.192.in-addr.arpa'
node.default['environment_v2']['domain']['top'] = 'internal'
node.default['environment_v2']['domain']['vip'] = 'svc'
node.default['environment_v2']['domain']['host'] = 'host'

##
## ports
##

node.default['environment_v2']['port']['kube-master'] = 50443
node.default['environment_v2']['port']['kube-master-insecure'] = 62080
node.default['environment_v2']['port']['ca-internal'] = 48888
node.default['environment_v2']['port']['ca'] = 58888
node.default['environment_v2']['port']['matchbox-http'] = 58080
node.default['environment_v2']['port']['matchbox-rpc'] = 58081
node.default['environment_v2']['port']['kea-dns'] = 53531

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
  ]
}

node.default['environment_v2']['set']['kea-mysql-data'] = {
  'hosts' => [
    'ns1',
    'ns2'
  ]
}

node.default['environment_v2']['set']['kea-mysql-mgm'] = {
  'hosts' => [
    'vm1',
  ]
}

node.default['environment_v2']['set']['haproxy'] = {
  'hosts' => [
    'vm1',
  ],
  'vip' => {
    'lan' => "192.168.62.242",
    'store' => "192.168.126.242",
  },
  'lb' => {
    'matchbox' => {
      "http" => {
        "hostport" => 48080,
        "port" => node['environment_v2']['port']['matchbox-http'],
      },
      "rpc" => {
        "hostport" => 48081,
        "port" => node['environment_v2']['port']['matchbox-rpc'],
      }
    },
    'ca' => {
      "default" => {
        "hostport" => node['environment_v2']['port']['ca-internal'],
        "port" => node['environment_v2']['port']['ca'],
      }
    },
    'kube-master' => {
      "default" => {
        "hostport" => 40443,
        "port" => node['environment_v2']['port']['kube-master'],
      }
    }
  }
}

node.default['environment_v2']['set']['matchbox'] = {
  'hosts' => [
    'vm1',
  ],
  'vars' => {
    'data_path' => "/data/matchbox"
  }
}

node.default['environment_v2']['set']['etcd'] = {
  'hosts' => [
    'vm1',
  ],
  'vars' => {
    'data_path' => "/data/etcd",
    'ssl_path' => "/etc/ssl/certs"
  }
}

node.default['environment_v2']['set']['ca'] = {
  'hosts' => [
    'vm1',
  ],
  'vars' => {
    'ssl_path' => "/data/certs"
  }
}

node.default['environment_v2']['set']['kube-master'] = {
  'hosts' => [
    'vm1',
  ]
}

node.default['environment_v2']['set']['kube-worker'] = {
  'hosts' => [
    # 'ns1',
    # 'ns2',
  ]
}

# node.default['environment_v2']['set']['vmhost'] = {
#   'hosts' => [
#     'vm1',
#   ],
# }


##
## hosts
##

node.default['environment_v2']['host']['gateway1'] = {
  'ip' => {
    'store' => "192.168.126.217",
    'lan' => "192.168.62.217",
  },
  'if' => {
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
  'memory' => 8192,
  'vcpu' => 3,
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
  'memory' => 8192,
  'vcpu' => 3,
}


##
## hardware
##

node.default['environment_v2']['host']['vm1'] = {
  'ip' => {
    'lan' => '192.168.62.251',
    'store' => '192.168.126.251',
  },
  'if' => {
    # 'lan' => "ens1f1",
    # 'store' => "ens1f0",
    'lan' => "lan_host",
    'store' => "store_host",
    'wan' => "eno2",
  },
  'guests' => [
    'gateway1',
    'gateway2',
    'ns1',
    'ns2',
  ]
}

# node.default['environment_v2']['host']['vm2'] = {
#   'ip' => {
#     'lan' => '192.168.62.252',
#     'store' => '192.168.126.252',
#   },
#   'if' => {
#     'lan' => "ens1f1",
#     'store' => "ens1f0",
#     'wan' => "eno2",
#   },
#   # 'passthrough_hba' => {
#   #   'domain' => "0x0000",
#   #   'bus' => "0x01",
#   #   'slot' => "0x00",
#   #   'function' => "0x0",
#   #   'file' => "/data/kvm/firmware/mptsas3.rom"
#   # }
#   'guests' => [
#     # 'gateway1',
#     # 'gateway2',
#   ]
# }

node.default['environment_v2']['host']['vm1-ipmi'] = {
  'ip' => {
    'store' => '192.168.127.61'
  }
}

node.default['environment_v2']['host']['vm2-ipmi'] = {
  'ip' => {
    'store' => '192.168.127.62'
  }
}

node.default['environment_v2']['host']['sw'] = {
  'ip' => {
    'store' => '192.168.127.94'
  }
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
    'store' => node['environment_v2']['set']['haproxy']['vip']['lan']
  }
}

node.default['environment_v2']['host']['unifi'] = {
  'ip' => {
    'lan' => node['environment_v2']['set']['haproxy']['vip']['lan']
  }
}
