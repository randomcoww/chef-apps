include_recipe "kubernetes-app::etcd"
include_recipe "kubernetes-app::flannel"
include_recipe "kubernetes-app::docker"

directory node['kubernetes']['kube_worker']['base_path'] do
  recursive true
  action [:create]
end

kubernetes_ca 'ca' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cert_path node['kubernetes']['kube_worker']['ca_path']
  action :create
end

kubernetes_node_cert 'worker' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cn "kube-#{node['hostname']}"
  key_path node['kubernetes']['kube_worker']['worker_key_path']
  cert_path node['kubernetes']['kube_worker']['worker_cert_path']
  alt_names ({
    'IP.1' => node['kubernetes']['node_ip']
  })
  action :create_if_missing
end
