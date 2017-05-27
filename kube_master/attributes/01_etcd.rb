node.default['kube_master']['etcd']['pkg_names'] = ['etcd']
node.default['kube_master']['etcd']['user'] = 'etcd'

node.default['kube_master']['etcd']['environment']['ETCD_NAME'] = node['hostname']
node.default['kube_master']['etcd']['environment']['ETCD_DATA_DIR'] = "/var/lib/etcd/kubernetes"
node.default['kube_master']['etcd']['environment']['ETCD_LISTEN_PEER_URLS'] = "http://#{node['kube_master']['node_ip']}:2380"
node.default['kube_master']['etcd']['environment']['ETCD_LISTEN_CLIENT_URLS'] = [node['kube_master']['node_ip'], '127.0.0.1'].map { |e|
    "http://#{e}:2379"
  }.join(',')

node.default['kube_master']['etcd']['environment']['ETCD_INITIAL_ADVERTISE_PEER_URLS'] = "http://#{node['kube_master']['node_ip']}:2380"
node.default['kube_master']['etcd']['environment']['ETCD_INITIAL_CLUSTER'] = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "#{e}=http://#{node['environment_v2']['host'][e]['ip_lan']}:2380"
  }.join(',')

## for now this needs to be manually set to either new or existing depending on cluster state
## i don't have a good solution to this
# node.default['kube_master']['etcd']['environment']['ETCD_INITIAL_CLUSTER_STATE'] = "new"
node.default['kube_master']['etcd']['environment']['ETCD_INITIAL_CLUSTER_STATE'] = "existing"

node.default['kube_master']['etcd']['environment']['ETCD_INITIAL_CLUSTER_TOKEN'] = "etcd-cluster-1"
node.default['kube_master']['etcd']['environment']['ETCD_ADVERTISE_CLIENT_URLS'] = "http://#{node['kube_master']['node_ip']}:2379"


node.default['kube_master']['etcd']['systemd_unit'] = {
  'Unit' => {
    'Description' => 'etcd key-value store',
    "After" => "network.target"
  },
  "Service" => {
    "Environment" => node['kube_master']['etcd']['environment'].map { |v|
      v.join('=')
    },
    "User" => node['kube_master']['etcd']['user'],
    "Type" => "notify",
    "ExecStart" => "/usr/bin/etcd",
    "Restart" => "always",
    "RestartSec" => "5s",
    "LimitNOFILE" => 40000
  },
  "Install" => {
    "WantedBy" => "multi-user.target"
  }
}

node.default['kube_master']['etcd']['nodes'] = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "http://#{node['environment_v2']['host'][e]['ip_lan']}:2379"
  }.join(',')
