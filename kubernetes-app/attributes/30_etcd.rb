node.default['kubernetes']['etcd']['environment']['ETCD_NAME'] = node['hostname']
node.default['kubernetes']['etcd']['environment']['ETCD_LISTEN_PEER_URLS'] = "http://#{node['kubernetes']['node_ip']}:2380"

node.default['kubernetes']['etcd']['environment']['ETCD_LISTEN_CLIENT_URLS'] = [node['kubernetes']['node_ip'], '127.0.0.1'].map { |e|
    "http://#{e}:2379"
  }.join(',')

node.default['kubernetes']['etcd']['environment']['ETCD_INITIAL_ADVERTISE_PEER_URLS'] = "http://#{node['kubernetes']['node_ip']}:2380"
node.default['kubernetes']['etcd']['environment']['ETCD_INITIAL_CLUSTER'] = node['environment_v2']['set']['etcd-kube']['hosts'].map { |e|
    "#{e}=http://#{node['environment_v2']['host'][e]['ip_lan']}:2380"
  }.join(',')

## for now this needs to be manually set to either new or existing depending on cluster state
## i don't have a good solution to this
# node.default['kubernetes']['etcd']['environment']['ETCD_INITIAL_CLUSTER_STATE'] = "new"
node.default['kubernetes']['etcd']['environment']['ETCD_INITIAL_CLUSTER_STATE'] = "existing"

node.default['kubernetes']['etcd']['environment']['ETCD_INITIAL_CLUSTER_TOKEN'] = "etcd-cluster-1"
node.default['kubernetes']['etcd']['environment']['ETCD_ADVERTISE_CLIENT_URLS'] = "http://#{node['kubernetes']['node_ip']}:2379"

node.default['kubernetes']['etcd']['nodes'] = node['environment_v2']['set']['etcd-kube']['hosts'].map { |e|
    "http://#{node['environment_v2']['host'][e]['ip_lan']}:2379"
  }.join(',')
