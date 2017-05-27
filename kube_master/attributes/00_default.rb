node.default['kube_master']['node_ip'] = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan']).first
node.default['kube_master']['service_ip_range'] = '10.254.0.0/16'
node.default['kube_master']['cluster_dns_ip'] = '10.254.0.10/16'

node.default['kube_master']['ssl_path'] = '/etc/kubernetes/ssl'

node.default['kube_master']['ca_path'] = ::File.join(node['kube_master']['ssl_path'], 'ca.crt')
node.default['kube_master']['cert_path'] = ::File.join(node['kube_master']['ssl_path'], 'server.crt')
node.default['kube_master']['key_path'] = ::File.join(node['kube_master']['ssl_path'], 'server.key')

node.default['kube_master']['config_path'] = '/etc/kubernetes/config'
node.default['kube_master']['manifests_path'] = '/etc/kubernetes/manifests'
