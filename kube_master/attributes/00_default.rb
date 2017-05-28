node.default['kube_master']['node_ip'] = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan']).first
node.default['kube_master']['service_ip_range'] = '10.254.0.0/16'
node.default['kube_master']['cluster_dns_ip'] = '10.254.0.10/16'
node.default['kube_master']['cluster_name'] = 'kube_cluster'


## cert and auth
node.default['kube_master']['srv_path'] = '/srv/kubernetes'
node.default['kube_master']['ca_path'] = ::File.join(node['kube_master']['srv_path'], 'ca.crt')
node.default['kube_master']['cert_path'] = ::File.join(node['kube_master']['srv_path'], 'server.crt')
node.default['kube_master']['key_path'] = ::File.join(node['kube_master']['srv_path'], 'server.key')

node.default['kube_master']['token_file_path'] = ::File.join(node['kube_master']['srv_path'], 'known_tokens.csv')
tokens_dbag = Dbag::Keystore.new(
    'deploy_config', 'kubernetes_auth'
  )

node.default['kube_master']['tokens'] = {
  'kubelet' => tokens_dbag.get_or_create('kubelet', SecureRandom.hex),
  'kube_proxy' => tokens_dbag.get_or_create('kube_proxy', SecureRandom.hex),
}


## pods
node.default['kube_master']['manifests_path'] = '/etc/kubernetes/manifests'
node.default['kube_master']['hyperkube_image'] = 'gcr.io/google_containers/hyperkube:v1.6.4'
