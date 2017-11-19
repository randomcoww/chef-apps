node.default['environment_v2']['subnet']['lan'] = "192.168.62.0/23"
node.default['environment_v2']['subnet']['store'] = "192.168.126.0/23"

node.default['environment_v2']['subnet']['dhcp_pool_lan'] = "192.168.62.32/27"
node.default['environment_v2']['subnet']['dhcp_pool_store'] = "192.168.126.32/27"
node.default['environment_v2']['domain']['rev_lan'] = '168.192.in-addr.arpa'

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

node.default['environment_v2']['set']['ns'] = {
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


node.default['environment_v2']['set']['haproxy'] = {
  'hosts' => [
    'coreos-kube-master',
  ],
  'vip_lan' => "192.168.62.242"
}

node.default['environment_v2']['set']['kube-master'] = {
  'hosts' => [
    'coreos-kube-master',
  ],
  'services' => {
    'kube-master' => {
      "port" => 20443,
      "proto" => "tcp"
    },
    'transmission' => {
      "port" => 30063,
      "proto" => "tcp"
    },
    'sshd' => {
      "port" => 32222,
      "proto" => "tcp"
    },
    'mpd-control' => {
      "port" => 30061,
      "proto" => "tcp"
    },
    'mpd-stream' => {
      "port" => 30062,
      "proto" => "tcp"
    }
  }
}


node.default['environment_v2']['set']['kube-worker'] = {
  'hosts' => [
    'coreos-kube-worker'
  ]
}

node.default['environment_v2']['set']['etcd'] = {
  'hosts' => [
    'coreos-etcd1',
    'coreos-etcd2',
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
    'coreos-kube-master',
    'coreos-kube-worker'
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

# node.default['environment_v2']['host']['coreos-etcd3'] = {
#   'if_lan' => 'eth0',
#   'memory' => 4096,
#   'vcpu' => 2
# }


node.default['environment_v2']['host']['coreos-kube-master'] = {
  'if_lan' => 'eth0',
  'memory' => 8192,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-kube-worker'] = {
  'if_lan' => 'eth0',
  'memory' => 8192,
  'vcpu' => 6
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

## load current host under 'current_host'
node.default['environment_v2']['node_name'] = ENV['NODE_NAME']
node.default['environment_v2']['node_host'] = node['environment_v2']['host'][node['environment_v2']['node_name']]
