node.default['kubernetes']['flannel']['pkg_names'] = ['flannel']

node.default['kubernetes']['flannel']['environment']['FLANNELD_ETCD_ENDPOINTS'] = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "http://#{node['environment_v2']['host'][e]['ip_lan']}:2379"
  }.join(',')

node.default['kubernetes']['flannel']['environment']['FLANNELD_ETCD_PREFIX'] = '/docker_overlay/network'
node.default['kubernetes']['flannel']['environment']['FLANNELD_SUBNET_DIR'] = '/run/flannel/networks'
node.default['kubernetes']['flannel']['environment']['FLANNELD_SUBNET_FILE'] = '/run/flannel/subnet.env'

node.default['kubernetes']['flannel']['etcd_network'] = {
  "Network" => node['kubernetes']['cluster_cidr'],
  "Backend" => {
    "Type" => "vxlan"
  }
}

node.default['kubernetes']['flannel']['systemd_unit'] = {
  'Unit' => {
    'Description' => 'Network fabric for containers',
    "After" => [
      "network.target",
      # 'etcd.service'
    ]
  },
  "Service" => {
    "Environment" => node['kubernetes']['flannel']['environment'].map { |v|
      v.join('=')
    },
    "Type" => "notify",
    "Restart" => "always",
    "RestartSec" => "5s",
    'ExecStartPre' => "/usr/bin/etcdctl --endpoints=#{node['kubernetes']['flannel']['environment']['FLANNELD_ETCD_ENDPOINTS']} set #{node['kubernetes']['flannel']['environment']['FLANNELD_ETCD_PREFIX']}/config '#{node['kubernetes']['flannel']['etcd_network'].to_json}'",
    'ExecStart' => "/usr/bin/flannel"
  },
  "Install" => {
    "WantedBy" => "multi-user.target"
  }
}
