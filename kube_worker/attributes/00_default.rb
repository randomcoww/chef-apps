node.default['kube_worker']['node_ip'] = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan']).first
node.default['kube_worker']['cluster_name'] = 'kube_cluster'
node.default['kube_worker']['cluster_domain'] = 'cluster.local'
node.default['kube_worker']['master_ip'] = node['environment_v2']['set']['haproxy']['vip_lan']


## pod network
node.default['kube_worker']['cluster_cidr'] = '10.2.0.0/16'

## service network
node.default['kube_worker']['service_ip_range'] = '10.3.0.0/24'
node.default['kube_worker']['cluster_service_ip'] = '10.3.0.1'
node.default['kube_worker']['cluster_dns_ip'] = '10.3.0.10'


## cert and auth
node.default['kube_worker']['srv_path'] = '/srv/kubernetes'
node.default['kube_worker']['ca_path'] = ::File.join(node['kube_worker']['srv_path'], 'ca.crt')
node.default['kube_worker']['cert_path'] = ::File.join(node['kube_worker']['srv_path'], 'server.crt')
node.default['kube_worker']['key_path'] = ::File.join(node['kube_worker']['srv_path'], 'server.key')


## pods
node.default['kube_worker']['manifests_path'] = '/etc/kubernetes/manifests'
