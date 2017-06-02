# include_recipe "kubernetes-app::etcd_client"
include_recipe "kubernetes-app::etcd"
include_recipe "kubernetes-app::flannel"
include_recipe "kubernetes-app::docker"
include_recipe 'kubernetes-app::kubernetes_packages'


kubernetes_ca 'ca' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cert_path node['kubernetes']['ca_path']
  action :create
end

kubernetes_node_cert 'worker' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cn "kube-#{node['hostname']}"
  key_path node['kubernetes']['key_path']
  cert_path node['kubernetes']['cert_path']
  alt_names ({
    'IP.1' => node['kubernetes']['node_ip']
  })
  action :create_if_missing
  subscribes :create, "kubernetes_ca[ca]", :immediately
end

## kubelet
directory ::File.dirname(node['kube_worker']['kubelet']['kubeconfig_path']) do
  recursive true
  action [:create]
end

file node['kube_worker']['kubelet']['kubeconfig_path'] do
  content node['kube_worker']['kubelet']['kubeconfig'].to_hash.to_yaml
  action :create
end

systemd_unit 'kubelet.service' do
  content node['kube_worker']['kubelet']['systemd']
  action [:create, :enable, :start]
  subscribes :restart, "kubernetes_ca[ca]", :delayed
end


## kube-proxy
directory ::File.dirname(node['kube_worker']['kube_proxy']['kubeconfig_path']) do
  recursive true
  action [:create]
end

file node['kube_worker']['kube_proxy']['kubeconfig_path'] do
  content node['kube_worker']['kube_proxy']['kubeconfig'].to_hash.to_yaml
  action :create
end

systemd_unit 'kube-proxy.service' do
  content node['kube_worker']['kube_proxy']['systemd']
  action [:create, :enable, :start]
  subscribes :restart, "kubernetes_ca[ca]", :delayed
end
