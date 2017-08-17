include_recipe "kubernetes-app::pod_kube_master"

include_recipe "kubernetes-app::_flannel"
include_recipe "kubernetes-app::_docker"
include_recipe "kubernetes-app::_static_pods"


[
  node['kubernetes']['srv_path'],
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end

## ssl
kubernetes_ca 'ca' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cert_path node['kubernetes']['ca_path']
  action :create
end

kubernetes_node_cert 'master' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cn "kube-#{node['hostname']}"
  key_path node['kubernetes']['key_path']
  cert_path node['kubernetes']['cert_path']
  alt_names ({
    'DNS.1' => 'kubernetes',
    'DNS.2' => 'kubernetes.default',
    'DNS.3' => 'kubernetes.default.svc',
    'DNS.4' => "kubernetes.default.svc.#{node['kubernetes']['cluster_domain']}",
    'IP.1' => node['kubernetes']['cluster_service_ip'],
    'IP.2' => node['kubernetes']['node_ip'],
    'IP.3' => node['kubernetes']['master_ip'],
  })
  action :create_if_missing
  subscribes :create, "kubernetes_ca[ca]", :immediately
end


[
  'kubelet',
  'kube_proxy',
].each do |e|
  remote_file node['kubernetes'][e]['binary_path'] do
    source node['kubernetes'][e]['remote_file']
    mode '0750'
    action :create_if_missing
  end
end

## kubelet
systemd_unit 'kubelet.service' do
  content node['kube_master']['kubelet']['systemd']
  action [:create, :enable, :start]
end

## kube-proxy
systemd_unit 'kube-proxy.service' do
  content node['kube_master']['kube_proxy']['systemd']
  action [:create, :enable, :start]
end
