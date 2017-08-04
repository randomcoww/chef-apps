nodeip = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan']).first

node.default['kubelet']['etcd']['environment']['ETCD_NAME'] = node['hostname']
node.default['kubelet']['etcd']['environment']['ETCD_LISTEN_PEER_URLS'] = "http://#{nodeip}:2380"
node.default['kubelet']['etcd']['environment']['ETCD_LISTEN_CLIENT_URLS'] = [nodeip, '127.0.0.1'].map { |e|
    "http://#{e}:2379"
  }.join(',')

node.default['kubelet']['etcd']['environment']['ETCD_INITIAL_ADVERTISE_PEER_URLS'] = "http://#{nodeip}:2380"
node.default['kubelet']['etcd']['environment']['ETCD_INITIAL_CLUSTER'] = node['environment_v2']['set']['etcd-flannel']['hosts'].map { |e|
    "#{e}=http://#{node['environment_v2']['host'][e]['ip_lan']}:2380"
  }.join(',')

node.default['kubelet']['etcd']['environment']['ETCD_INITIAL_CLUSTER_STATE'] = "new"
# node.default['kubelet']['etcd']['environment']['ETCD_INITIAL_CLUSTER_STATE'] = "existing"

node.default['kubelet']['etcd']['environment']['ETCD_INITIAL_CLUSTER_TOKEN'] = "etcd-cluster-1"
node.default['kubelet']['etcd']['environment']['ETCD_ADVERTISE_CLIENT_URLS'] = "http://#{nodeip}:2379"
