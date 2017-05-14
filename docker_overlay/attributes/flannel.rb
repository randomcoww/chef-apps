node.default['docker_overlay']['flannel']['pkg_names'] = ['flannel']

node.default['docker_overlay']['flannel']['environment']['FLANNELD_ETCD_ENDPOINTS'] = node['environment_v2']['set']['docker']['hosts'].map { |e|
    "http://#{node['environment_v2']['host'][e]['ip_lan']}:2379"
  }.join(',')

node.default['docker_overlay']['flannel']['environment']['FLANNELD_ETCD_PREFIX'] = '/docker_overlay/network'
node.default['docker_overlay']['flannel']['environment']['FLANNELD_SUBNET_DIR'] = '/run/flannel/networks'
node.default['docker_overlay']['flannel']['environment']['FLANNELD_SUBNET_FILE'] = '/run/flannel/subnet.env'

node.default['docker_overlay']['flannel']['etcd_network'] = {
  "Network" => "10.20.0.0/16",
  "SubnetLen" => 24,
  "Backend" => {
    "Type" => "vxlan",
    "VNI" => 1
  }
}

node.default['docker_overlay']['flannel']['systemd_unit'] = {
  'Unit' => {
    'Description' => 'Network fabric for containers',
    "After" => [
      "network.target",
      'etcd.service'
    ]
  },
  "Service" => {
    "Environment" => node['docker_overlay']['flannel']['environment'].map { |v|
      v.join('=')
    },
    "Type" => "notify",
    "Restart" => "always",
    "RestartSec" => "5s",
    'ExecStartPre' => "-/usr/bin/etcdctl set #{node['docker_overlay']['flannel']['environment']['FLANNELD_ETCD_PREFIX']}/config '#{node['docker_overlay']['flannel']['etcd_network'].to_json}'",
    'ExecStart' => "/usr/bin/flannel",
    'ConditionPathExists' => node['docker_overlay']['flannel']['environment']['FLANNELD_SUBNET_DIR'],
    'ConditionFileNotEmpty' => node['docker_overlay']['flannel']['environment']['FLANNELD_SUBNET_FILE']
  },
  "Install" => {
    "WantedBy" => "multi-user.target"
  }
}
