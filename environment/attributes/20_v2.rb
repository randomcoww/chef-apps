node.default['environment_v2']['subnet']['lan'] = "192.168.62.0/23"
node.default['environment_v2']['subnet']['store'] = "192.168.126.0/23"
node.default['environment_v2']['subnet']['metallb'] = "192.168.127.128/25"

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

node.default['environment_v2']['port']['controller'] = 56443
node.default['environment_v2']['port']['matchbox-http'] = 58080
node.default['environment_v2']['port']['matchbox-rpc'] = 58081
node.default['environment_v2']['port']['etcd'] = 52379
node.default['environment_v2']['port']['etcd-peer'] = 52380
node.default['environment_v2']['port']['unbound'] = 53

##
## sets
##

node.default['environment_v2']['set']['gateway'] = {
  'hosts' => [
    'provisioner',
  ],
  'vip' => {
    'store' => "192.168.126.240",
    'lan' => "192.168.62.240",
  }
}

node.default['environment_v2']['set']['dns'] = {
  'vip' => {
    'store' => "192.168.127.254",
    'lan' => "192.168.127.254",
  }
}

node.default['environment_v2']['set']['kea'] = {
  'hosts' => [
    'provisioner',
  ],
  'vars' => {
    'mount_path' => "/data/kea",
    'lease_path' => "/var/lib/kea",
  }
}

node.default['environment_v2']['set']['matchbox'] = {
  'hosts' => [
    'provisioner',
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
  'health_check' => "nc -z -w5 localhost #{node['environment_v2']['port']['matchbox-http']}",
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
  'health_check' => "nc -z -w5 localhost #{node['environment_v2']['port']['controller']}"
}

node.default['environment_v2']['set']['kube-worker'] = {
  'hosts' => [
    "worker",
  ]
}


##
## hosts
##

node.default['environment_v2']['host']['provisioner'] = {
  'if' => {
    'lan' => "eth0",
    'store' => "eth1",
    'wan' => "eth2",
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

node.default['environment_v2']['host']['worker'] = {}


##
## hardware
##

node.default['environment_v2']['host']['store-0'] = {
  'ip' => {
    'store' => '192.168.126.251',
  }
}

node.default['environment_v2']['host']['store-1'] = {
  'ip' => {
    'store' => '192.168.126.252',
  },
  # 'passthrough_hba' => {
  #   'domain' => "0x0000",
  #   'bus' => "0x01",
  #   'slot' => "0x00",
  #   'function' => "0x0",
  #   'file' => "/data/kvm/firmware/mptsas3.rom"
  # }
}

node.default['environment_v2']['host']['store-1-ipmi'] = {
  'ip' => {
    'store' => '192.168.127.61'
  }
}

node.default['environment_v2']['host']['store-2-ipmi'] = {
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
