node.default['environment_v2']['subnet']['lan'] = "192.168.62.0/23"
node.default['environment_v2']['subnet']['store'] = "192.168.126.0/23"

node.default['environment_v2']['dhcp_pool']['lan'] = "192.168.62.0/25"
node.default['environment_v2']['dhcp_pool']['store'] = "192.168.126.0/25"

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
    'lan' => "192.168.62.240",
    'store' => "192.168.126.240",
  }
}

node.default['environment_v2']['set']['ns'] = {
  'hosts' => [
    'gateway1',
    'gateway2'
  ],
  'vip' => {
    'lan' => "192.168.62.241",
    'store' => "192.168.126.241",
  }
}

node.default['environment_v2']['set']['kea'] = {
  'hosts' => [
    'gateway1',
    'gateway2'
  ]
}


node.default['environment_v2']['set']['haproxy'] = {
  'hosts' => [
    'kube-master',
  ],
  'vip' => {
    'store' => "192.168.126.242",
  }
}

node.default['environment_v2']['set']['kube-master'] = {
  'hosts' => [
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

node.default['environment_v2']['set']['etcd'] = {
  'hosts' => [
    'etcd1',
    'etcd2',
  ],
  "services" => {
    'etcd-server-ssl' => {
      "port" => 2380,
      "proto" => "tcp",
    },
    'etcd-client-ssl' => {
      "port" => 2379,
      "proto" => "tcp"
    }
  }
}

node.default['environment_v2']['set']['flannel'] = {
  'hosts' => [
    'kube-master',
    'kube-worker'
  ]
}


##
## hosts
##

node.default['environment_v2']['host']['gateway1'] = {
  'ip' => {
    'lan' => "192.168.62.217",
    'store' => "192.168.126.217",
  },
  'if' => {
    'lan' => "eth0",
    'store' => "eth1",
    'wan' => "eth2",
  },
  'mac' => {
    "wan" => "52:54:00:63:6e:b0"
  },
  'memory' => 8192,
  'vcpu' => 2
}

node.default['environment_v2']['host']['gateway2'] = {
  'ip' => {
    'lan' => "192.168.62.218",
    'store' => "192.168.126.218",
  },
  'if' => {
    'lan' => "eth0",
    'store' => "eth1",
    'wan' => "eth2",
  },
  'mac' => {
    "wan" => "52:54:00:63:6e:b1"
  },
  'memory' => 8192,
  'vcpu' => 2
}

node.default['environment_v2']['host']['etcd1'] = {
  'if' => {
    'store' => "eth0",
  },
  'memory' => 4096,
  'vcpu' => 2
}

node.default['environment_v2']['host']['etcd2'] = {
  'if' => {
    'store' => "eth0",
  },
  'memory' => 4096,
  'vcpu' => 2
}


node.default['environment_v2']['host']['kube-master'] = {
  'if' => {
    'store' => "eth0",
  },
  'memory' => 8192,
  'vcpu' => 2
}

node.default['environment_v2']['host']['kube-worker'] = {
  'if' => {
    'store' => "eth0",
  },
  'memory' => 8192,
  'vcpu' => 6
}


##
## hardware
##

node.default['environment_v2']['host']['vm1'] = {
  'ip' => {
    'store' => '192.168.126.251',
  },
  'if' => {
    'lan' => "eno1",
    'wan' => "eno2",
    'store' => "ens1",
  },
  # 'passthrough_hba' => {
  #   'domain' => "0x0000",
  #   'bus' => "0x01",
  #   'slot' => "0x00",
  #   'function' => "0x0",
  #   'file' => "/data/kvm/firmware/mptsas3.rom"
  # }
  'guests' => [
    'gateway1', 'gateway2',
    'etcd1', 'etcd2',
    'kube-master',
    'kube-worker'
  ]
}

node.default['environment_v2']['host']['vm2'] = {
  'ip' => {
    'store' => '192.168.126.252',
  },
  'if' => {
    'lan' => "eno1",
    'wan' => "eno2",
    'store' => "ens1",
  },
  # 'passthrough_hba' => {
  #   'domain' => "0x0000",
  #   'bus' => "0x01",
  #   'slot' => "0x00",
  #   'function' => "0x0",
  #   'file' => "/data/kvm/firmware/mptsas3.rom"
  # }
}

node.default['environment_v2']['host']['vm1-ipmi'] = {
  'ip' => {
    'lan' => '192.168.63.61'
  }
}

node.default['environment_v2']['host']['vm2-ipmi'] = {
  'ip' => {
    'lan' => '192.168.63.62'
  }
}

node.default['environment_v2']['host']['sw'] = {
  'ip' => {
    'lan' => '192.168.63.95'
  }
}

## load current host under 'current_host'
# node.default['environment_v2']['node_name'] = ENV['NODE_NAME']
# node.default['environment_v2']['node_host'] = node['environment_v2']['host'][node['environment_v2']['node_name']]
