node.default['kube_worker']['node_ip'] = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan']).first
node.default['kube_worker']['service_ip_range'] = '10.254.0.0/16'
node.default['kube_worker']['cluster_dns_ip'] = '10.254.0.10/16'
node.default['kube_worker']['cluster_name'] = 'kube_cluster'
node.default['kube_worker']['master_ip'] = node['environment_v2']['set']['haproxy']['vip_lan']


## cert and auth
node.default['kube_worker']['srv_path'] = '/srv/kubernetes'
node.default['kube_worker']['ca_path'] = ::File.join(node['kube_worker']['srv_path'], 'ca.crt')
node.default['kube_worker']['cert_path'] = ::File.join(node['kube_worker']['srv_path'], 'server.crt')
node.default['kube_worker']['key_path'] = ::File.join(node['kube_worker']['srv_path'], 'server.key')

node.default['kube_worker']['token_file_path'] = ::File.join(node['kube_worker']['srv_path'], 'known_tokens.csv')
tokens_dbag = Dbag::Keystore.new(
    'deploy_config', 'kubernetes_auth'
  )

node.default['kube_worker']['tokens'] = {
  'kubelet' => tokens_dbag.get_or_create('kubelet', SecureRandom.hex),
  'kube_proxy' => tokens_dbag.get_or_create('kube_proxy', SecureRandom.hex),
}


## pods
node.default['kube_worker']['manifests_path'] = '/etc/kubernetes/manifests'
