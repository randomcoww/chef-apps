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

node.default['environment_v2']['port']['controller'] = 56443
node.default['environment_v2']['port']['controller-internal'] = 56443

node.default['environment_v2']['port']['matchbox-http'] = 58080
node.default['environment_v2']['port']['matchbox-rpc'] = 58081
node.default['environment_v2']['port']['matchbox-http-internal'] = 58080
node.default['environment_v2']['port']['matchbox-rpc-internal'] = 58081

node.default['environment_v2']['port']['etcd'] = 52379
node.default['environment_v2']['port']['unbound-dns'] = 53


##
## sets
##

node.default['environment_v2']['set']['gateway'] = {
  'hosts' => [
    'provisioner-0',
  ],
  'vip' => {
    'store' => "192.168.126.240",
    'lan' => "192.168.62.240",
  }
}

node.default['environment_v2']['set']['dns'] = {
  'hosts' => [
    'provisioner-0',
  ],
  'vip' => {
    'store' => "192.168.126.244",
    'lan' => "192.168.62.244",
  },
  'health_check' => "nc -z -w5 localhost #{node['environment_v2']['port']['unbound-dns']}"
}

node.default['environment_v2']['set']['kea'] = {
  'hosts' => [
    'provisioner-0',
  ],
  'vars' => {
    'mount_path' => "/data/kea",
    'lease_path' => "/var/lib/kea",
  }
}

node.default['environment_v2']['set']['matchbox'] = {
  'hosts' => [
    'provisioner-0',
  ],
  'vars' => {
    'mount_path' => "/data/matchbox",
    'data_path' => "/var/lib/matchbox",
    'assets_path' => "/var/lib/matchbox/assets",
    'ssl_path' => "/etc/ssl/certs"
  },
  'vip' => {
    'store' => "192.168.126.242",
  },
  'health_check' => "nc -z -w5 localhost #{node['environment_v2']['port']['matchbox-http-internal']}",
}

node.default['environment_v2']['set']['etcd'] = {
  'hosts' => [
    'controller-0',
  ],
  'vars' => {
    'mount_path' => "/data/etcd",
    'etcd_path' => "/var/lib/etcd",
    'ssl_path' => "/etc/ssl/certs"
  }
}

node.default['environment_v2']['set']['kube-master'] = {
  'hosts' => [
    "controller-0",
  ],
  'vip' => {
    'store' => "192.168.126.245",
  },
  'health_check' => "nc -z -w5 localhost #{node['environment_v2']['port']['controller-internal']}",
  # 'lb' => {
  #   'kube-master' => {
  #     "default" => {
  #       "hostport" => node['environment_v2']['port']['controller-internal'],
  #       "port" => node['environment_v2']['port']['controller'],
  #     }
  #   }
  # }
}

node.default['environment_v2']['set']['kube-worker'] = {
  'hosts' => [
    "worker-0",
  ],
  # 'vip' => {
  #   'store' => "192.168.126.246",
  # }
}


##
## hosts
##

node.default['environment_v2']['host']['provisioner-0'] = {
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

node.default['environment_v2']['host']['controller-0'] = {
  'ip' => {
    'store' => "192.168.126.219",
  },
  'if' => {
    'store' => "eth0",
  }
}

node.default['environment_v2']['host']['worker-0'] = {
  'if' => {
    'store' => "eth0",
  }
}


##
## hardware
##

node.default['environment_v2']['host']['store-0'] = {
  'ip' => {
    'store' => '192.168.126.251',
    'lan' => '192.168.62.251',
  },
  'if' => {
    'store' => "store_bridge",
    'lan' => "lan_bridge",
  }
}

node.default['environment_v2']['host']['store-1'] = {
  'ip' => {
    'store' => '192.168.126.252',
  },
  'if' => {
    'store' => "store_bridge",
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
    'store' => node['environment_v2']['host']['store-0']['ip']['store'],
  }
}
