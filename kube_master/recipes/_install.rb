include_recipe "kube_master::etcd"
include_recipe "kube_master::flannel"
include_recipe "kube_master::docker"

[
  node['kube_master']['srv_path'],
  node['kube_master']['manifests_path']
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end


kubernetes_ca 'ca' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cert_path node['kube_master']['ca_path']
  action :create
end

kubernetes_node_cert 'master' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cn 'kube-apiserver'
  key_path node['kube_master']['key_path']
  cert_path node['kube_master']['cert_path']
  alt_names ({
    'DNS.1' => 'kube_master',
    'DNS.2' => 'kubernetes.default',
    'DNS.3' => 'kubernetes.default.svc',
    'DNS.4' => 'kubernetes.default.svc.cluster.local',
    'IP.1' => node['kube_master']['node_ip'],
    'IP.2' => node['environment_v2']['set']['haproxy']['vip_lan'],
  })
  action :create_if_missing
end


file node['kube_master']['token_file_path'] do
  content (node['kube_master']['tokens'].map.with_index { |kv, i|
      [kv[1], kv[0], i].join(',')
    }.join($/))
  action :create
end


include_recipe "kube_master::kubelet"
include_recipe "kube_master::kube_proxy"

include_recipe "kube_master::manifests"
