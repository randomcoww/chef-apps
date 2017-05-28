node.default['kube_master']['flannel']['pkg_names'] = ['flannel']

node.default['kube_master']['flannel']['environment']['FLANNELD_ETCD_ENDPOINTS'] = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "http://#{node['environment_v2']['host'][e]['ip_lan']}:2379"
  }.join(',')

node.default['kube_master']['flannel']['environment']['FLANNELD_ETCD_PREFIX'] = '/docker_overlay/network'
node.default['kube_master']['flannel']['environment']['FLANNELD_SUBNET_DIR'] = '/run/flannel/networks'
node.default['kube_master']['flannel']['environment']['FLANNELD_SUBNET_FILE'] = '/run/flannel/subnet.env'

node.default['kube_master']['flannel']['etcd_network'] = {
  "Network" => node['kube_master']['cluster_cidr'],
  "Backend" => {
    "Type" => "vxlan"
  }
}

node.default['kube_master']['flannel']['systemd_unit'] = {
  'Unit' => {
    'Description' => 'Network fabric for containers',
    "After" => [
      "network.target",
      'etcd.service'
    ]
  },
  "Service" => {
    "Environment" => node['kube_master']['flannel']['environment'].map { |v|
      v.join('=')
    },
    "Type" => "notify",
    "Restart" => "always",
    "RestartSec" => "5s",
    'ExecStartPre' => "-/usr/bin/etcdctl set #{node['kube_master']['flannel']['environment']['FLANNELD_ETCD_PREFIX']}/config '#{node['kube_master']['flannel']['etcd_network'].to_json}'",
    'ExecStart' => "/usr/bin/flannel"
  },
  "Install" => {
    "WantedBy" => "multi-user.target"
  }
}
