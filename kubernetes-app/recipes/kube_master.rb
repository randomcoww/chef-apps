include_recipe "docker_overlay::etcd"
include_recipe "docker_overlay::flannel"
include_recipe "docker_overlay::docker"

directory node['kubernetes']['kube_master']['base_path'] do
  recursive true
  action [:create]
end

kubernetes_ca 'ca' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cert_path node['kubernetes']['kube_master']['ca_path']
  action :create
end

kubernetes_node_cert 'apiserver' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cn 'kube-apiserver'
  key_path node['kubernetes']['kube_master']['apiserver_key_path']
  cert_path node['kubernetes']['kube_master']['apiserver_cert_path']
  alt_names ({
    'DNS.1' => 'kubernetes',
    'DNS.2' => 'kubernetes.default',
    'DNS.3' => 'kubernetes.default.svc',
    'DNS.4' => 'kubernetes.default.svc.cluster.local',
    'IP.1' => node['kubernetes']['node_ip'],
    'IP.2' => node['environment_v2']['set']['haproxy']['vip_lan'],
  })
  action :create_if_missing
end

include_recipe "docker_overlay::kube_apiserver"
include_recipe "docker_overlay::kube_controller_manager"
include_recipe "docker_overlay::kube_proxy"
include_recipe "docker_overlay::kube_scheduler"
