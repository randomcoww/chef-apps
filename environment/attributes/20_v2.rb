node.default['environment_v2']['subnet']['lan'] = "192.168.62.0/23"
node.default['environment_v2']['subnet']['store'] = "192.168.126.0/23"
node.default['environment_v2']['subnet']['sync'] = "192.168.190.0/23"

node.default['environment_v2']['netmask']['lan'] = '255.255.254.0'
node.default['environment_v2']['netmask']['store'] = '255.255.254.0'
node.default['environment_v2']['netmask']['sync'] = '255.255.254.0'

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
node.default['environment_v2']['port']['kube-master-internal'] = 40443
node.default['environment_v2']['port']['kube-master-insecure'] = 62080
node.default['environment_v2']['port']['vault'] = 48889
node.default['environment_v2']['port']['matchbox-http'] = 58080
node.default['environment_v2']['port']['matchbox-rpc'] = 58081
node.default['environment_v2']['port']['etcd'] = 52379
node.default['environment_v2']['port']['kea-dns'] = 53531
node.default['environment_v2']['port']['unbound-dns'] = 53

##
## sets
##

node.default['environment_v2']['set']['gateway'] = {
  'hosts' => [
    'gateway1',
    'gateway2',
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
    'ns3'
  ],
  ## unbound, dnsdist
  'vip' => {
    'store' => "192.168.126.244",
    'lan' => "192.168.62.244",
  },
  'health_check' => "nc -z -w5 localhost 53"
}

node.default['environment_v2']['set']['kea-mysql-data'] = {
  'hosts' => [
    'ns1',
    'ns2'
  ],
  ## kea, mysql, kea-resolver, dnsdist
  'vip' => {
    'store' => "192.168.126.241",
  },
  'health_check' => "nc -z -w5 localhost #{node['environment_v2']['port']['kea-dns']}"
}

## mysql-mgm
node.default['environment_v2']['set']['kea-mysql-mgm'] = {
  'hosts' => [
    'ns3',
  ]
}

node.default['environment_v2']['set']['haproxy'] = {
  'hosts' => [
    'vmhost1',
  ],
  'vip' => {
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
    'etcd' => {
      'default' => {
        "hostport" => 2379,
        "port" => node['environment_v2']['port']['etcd'],
      }
    }
  }
}

node.default['environment_v2']['set']['matchbox'] = {
  'hosts' => [
    'vmhost1',
  ],
  'vars' => {
    'ssl_path' => "/etc/ssl/certs",
  }
}

node.default['environment_v2']['set']['etcd'] = {
  'hosts' => [
    'vmhost1',
  ],
  'vars' => {
    'data_path' => "/data/etcd",
    'ssl_path' => "/etc/ssl/certs"
  },
  ## vault
  'vip' => {
    'store' => "192.168.126.243",
  },
  'health_check' => "nc -z -w5 localhost #{node['environment_v2']['port']['vault']}"
}

node.default['environment_v2']['set']['kube-master'] = {
  'hosts' => [
    "controller"
  ],
  'vars' => {
    'ssl_path' => "/etc/ssl/certs"
  },
  'vip' => {
    'store' => "192.168.126.245",
  },
  'health_check' => "nc -z -w5 localhost #{node['environment_v2']['port']['kube-master-internal']}"
}

node.default['environment_v2']['set']['kube-worker'] = {
  'hosts' => [
    # 'ns1',
    # 'ns2',
  ]
}


##
## hosts
##

node.default['environment_v2']['host']['gateway1'] = {
  'ip' => {
    'store' => "192.168.126.217",
    'lan' => "192.168.62.217",
    'sync' => "192.168.190.217",
  },
  'if' => {
    'lan' => "eth0",
    'store' => "eth1",
    'wan' => "eth2",
    'sync' => "eth3",
  }
}

node.default['environment_v2']['host']['gateway2'] = {
  'ip' => {
    'store' => "192.168.126.218",
    'lan' => "192.168.62.218",
    'sync' => "192.168.190.218",
  },
  'if' => {
    'lan' => "eth0",
    'store' => "eth1",
    'wan' => "eth2",
    'sync' => "eth3",
  }
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
  }
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
  }
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
  }
}

node.default['environment_v2']['host']['controller'] = {
  'if' => {
    'store' => "eth0",
  }
}


##
## hardware
##

node.default['environment_v2']['host']['vmhost1'] = {
  'ip' => {
    'store' => '192.168.126.251',
  },
  'if' => {
    'store' => "host_bridge",
  }
}

node.default['environment_v2']['host']['vmhost2'] = {
  'ip' => {
    'store' => '192.168.126.252',
  },
  'if' => {
    'store' => "host_bridge",
  },
  # 'passthrough_hba' => {
  #   'domain' => "0x0000",
  #   'bus' => "0x01",
  #   'slot' => "0x00",
  #   'function' => "0x0",
  #   'file' => "/data/kvm/firmware/mptsas3.rom"
  # }
}

node.default['environment_v2']['host']['vmhost1-ipmi'] = {
  'ip' => {
    'store' => '192.168.127.61'
  }
}

node.default['environment_v2']['host']['vmhost2-ipmi'] = {
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
    'store' => node['environment_v2']['host']['vmhost1']['ip']['store'],
  }
}

node.default['environment_v2']['set']['transmission'] = {
  'vip' => {
    'store' => node['environment_v2']['set']['kube-master']['vip']['store']
  }
}

node.default['environment_v2']['set']['unifi'] = {
  'vip' => {
    'store' => node['environment_v2']['set']['kube-master']['vip']['store']
  }
}

## for auto discovery by APs
node.default['environment_v2']['host']['unifi'] = {
  'ip' => {
    'lan' => node['environment_v2']['set']['kube-master']['vip']['store']
  }
}
