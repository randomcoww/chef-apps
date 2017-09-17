node.default['environment_v2']['ssh_authorized_keys']['default'] = [
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCf4YDpCaridIv8B4LIj8zYVbRfEgDvstlFu4nllhfY9UEcoHgBHEDmCFe1+qsv3flxTm7Q5v4q6RIETS2AwzRTlSTyzcI6t8jQ16R6aoLcbU2J2kWsD/rGHAuHGtZb2950rApIfOdP4n05uW34We6ErZmlCC0R/x9JIP5QqvoJE9KaVC3v/vPG1KVsYZFxtyKVHnFwwPlzjtHp+Tq0xG7jCPG5w+fekpvcImxo8isunRkpyHQFRE0nQAlIfCmJ1LdG3PREswuinKHiW33hXqkRVCSXmF2PGLW+x9aWvcMgbguX9WGWO4Dafta2lzwN6x4QWmc6bQpO1akw3Qi5rzQN',
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDV32iY0Sg4ZrLBg8MzUGtwteIJn4CpqxRLCRv/ayGBIbv8yRD0zR5K8mT2lh9NjST0g84W8x8MZswnurTzD/a9FyQzD9nOGCpe+PMFlOPg9oArZO0GOa74j36aRKdMou+/URi37EMc5caQPGbKzez7ylj4LKsznoeRQuIGDFE1kwatTXvH9alb/lp1jX97fcesEVc0r28MEU70lmfc9tdkF3+9gpzztDrrg0zdsuE8l9LtnbMK+SVbXASjLbkYDjBn6qP8zmv1gFOLz09N+/0C6Jsqzmxxa5KW5f6DfnYv1i3Ov+1lbN8L7709/qcVZs6kG9jsuYiyAjrsouu7jlNj'
]

node.default['environment_v2']['subnet']['lan'] = "192.168.62.0/23"
node.default['environment_v2']['subnet']['store'] = "192.168.126.0/23"
node.default['environment_v2']['subnet']['vpn'] = "192.168.30.0/23"
node.default['environment_v2']['subnet']['lan_dhcp_pool'] = "192.168.62.32/27"
node.default['environment_v2']['subnet']['vpn_dhcp_pool'] = "192.168.30.32/27"

node.default['environment_v2']['domain']['top'] = 'lan'
node.default['environment_v2']['domain']['host_lan'] = 'hl'
node.default['environment_v2']['domain']['vip_lan'] = 'vl'
node.default['environment_v2']['domain']['host_store'] = 'hs'
node.default['environment_v2']['domain']['vip_store'] = 'vs'


##
## sets
##

node.default['environment_v2']['set']['dns'] = {
  'hosts' => [
    'coreos-dns1',
    'coreos-dns2'
  ]

}

node.default['environment_v2']['set']['kea'] = {
  'hosts' => [
    # 'coreos-kea1',
    # 'coreos-kea2'
    'coreos-dns1',
    'coreos-dns2'
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

node.default['environment_v2']['set']['gateway'] = {
  'hosts' => [
    'coreos-gateway1',
    'coreos-gateway2'
  ],
  'vip_lan' => "192.168.62.240"
}

node.default['environment_v2']['set']['etcd'] = {
  'hosts' => [
    'coreos-etcd1',
    'coreos-etcd2',
    'coreos-etcd3',
  ]
}

node.default['environment_v2']['set']['gluster'] = {
  'hosts' => [
    'vm1',
    'vm2'
  ],
  'vip_lan' => "192.168.62.250",
  'vip_store' => "192.168.126.250"
}


##
## hosts
##

node.default['environment_v2']['host']['coreos-dns1'] = {
  'ip_lan' => "192.168.62.211",
  'if_lan' => 'eth0',
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-dns2'] = {
  'ip_lan' => "192.168.62.212",
  'if_lan' => 'eth0',
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-kea1'] = {
  'ip_lan' => "192.168.62.213",
  'if_lan' => 'eth0',
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-kea2'] = {
  'ip_lan' => "192.168.62.214",
  'if_lan' => 'eth0',
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-gateway1'] = {
  'ip_lan' => "192.168.62.217",
  'mac_wan' => "52:54:00:63:6e:b0",
  'if_lan' => 'ens2',
  'if_wan' => 'ens3',
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-gateway2'] = {
  'ip_lan' => "192.168.62.218",
  'mac_wan' => "52:54:00:63:6e:b1",
  'if_lan' => 'ens2',
  'if_wan' => 'ens3',
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-etcd1'] = {
  'ip_lan' => "192.168.62.219",
  'if_lan' => 'eth0',
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-etcd2'] = {
  'ip_lan' => "192.168.62.220",
  'if_lan' => 'eth0',
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-etcd3'] = {
  'ip_lan' => "192.168.62.221",
  'if_lan' => 'eth0',
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-kube-master1'] = {
  'ip_lan' => "192.168.62.222",
  'if_lan' => 'eth0',
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-kube-master2'] = {
  'ip_lan' => "192.168.62.223",
  'if_lan' => 'eth0',
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-kube-worker1'] = {
  'ip_lan' => "192.168.62.224",
  'ip_store' => "192.168.126.224",
  'if_lan' => 'eth0',
  'if_store' => 'eth1',
  'memory' => 2048,
  'vcpu' => 2
}

node.default['environment_v2']['host']['coreos-kube-worker2'] = {
  'ip_lan' => "192.168.62.225",
  'ip_store' => "192.168.126.225",
  'if_lan' => 'eth0',
  'if_store' => 'eth1',
  'memory' => 2048,
  'vcpu' => 2
}


##
## one off
##

node.default['environment_v2']['host']['unifi'] = {
  'ip_lan' => "192.168.62.100",
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
  # 'vf_lan' => 'eno1',
  # 'vf_wan' => 'eno2',
  # 'vf_store' => 'ens1',
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
  # 'vf_lan' => 'eno1',
  # 'vf_wan' => 'eno2',
  # 'vf_store' => 'ens1',
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
# node.default['environment_v2']['current_host'] = node['environment_v2']['host'][node['hostname']]
node.default['environment_v2']['current_host'] = node['environment_v2']['host'][ENV['NODE_NAME']]
