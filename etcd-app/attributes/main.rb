node.default['etcd']['main']['version'] = '3.1.7'

node_ip = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan']).first

node.default['etcd']['main']['user'] = 'etcd'

node.default['etcd']['main']['environment']['ETCD_NAME'] = node['hostname']
node.default['etcd']['main']['environment']['ETCD_DATA_DIR'] = "/var/lib/etcd"
node.default['etcd']['main']['environment']['ETCD_LISTEN_PEER_URLS'] = "http://#{node_ip}:2380"
node.default['etcd']['main']['environment']['ETCD_LISTEN_CLIENT_URLS'] = [node_ip, '127.0.0.1'].map { |e|
    "http://#{e}:2379"
  }.join(',')

node.default['etcd']['main']['environment']['ETCD_INITIAL_ADVERTISE_PEER_URLS'] = "http://#{node_ip}:2380"
node.default['etcd']['main']['environment']['ETCD_INITIAL_CLUSTER'] = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "#{e}=http://#{node['environment_v2']['host'][e]['ip_lan']}:2380"
  }.join(',')

## for now this needs to be manually set to either new or existing depending on cluster state
## i don't have a good solution to this
# node.default['etcd']['main']['environment']['ETCD_INITIAL_CLUSTER_STATE'] = "new"
node.default['etcd']['main']['environment']['ETCD_INITIAL_CLUSTER_STATE'] = "existing"

node.default['etcd']['main']['environment']['ETCD_INITIAL_CLUSTER_TOKEN'] = "etcd-cluster-1"
node.default['etcd']['main']['environment']['ETCD_ADVERTISE_CLIENT_URLS'] = "http://#{node_ip}:2379"


node.default['etcd']['main']['systemd_unit'] = {
  'Unit' => {
    'Description' => 'etcd key-value store',
    "After" => "network.target"
  },
  "Service" => {
    "Environment" => node['etcd']['main']['environment'].map { |v|
      v.join('=')
    },
    "User" => node['etcd']['main']['user'],
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
