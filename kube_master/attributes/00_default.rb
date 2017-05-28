node.default['kube_master']['node_ip'] = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan']).first
node.default['kube_master']['cluster_name'] = 'kube_cluster'
node.default['kube_master']['master_ip'] = node['environment_v2']['set']['haproxy']['vip_lan']


## pod network
node.default['kube_master']['cluster_cidr'] = '10.2.0.0/16'

## service network
node.default['kube_master']['service_ip_range'] = '10.3.0.0/24'
node.default['kube_master']['cluster_service_ip'] = '10.3.0.1'
node.default['kube_master']['cluster_dns_ip'] = '10.3.0.10'


## cert and auth
node.default['kube_master']['srv_path'] = '/srv/kubernetes'
node.default['kube_master']['ca_path'] = ::File.join(node['kube_master']['srv_path'], 'ca.crt')
node.default['kube_master']['cert_path'] = ::File.join(node['kube_master']['srv_path'], 'server.crt')
node.default['kube_master']['key_path'] = ::File.join(node['kube_master']['srv_path'], 'server.key')


## pods
node.default['kube_master']['manifests_path'] = '/etc/kubernetes/manifests'
node.default['kube_master']['hyperkube_image'] = 'gcr.io/google_containers/hyperkube:v1.6.4'
