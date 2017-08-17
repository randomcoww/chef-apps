node.default['kubernetes']['docker']['systemd_dropin'] = {
  'Service' => {
    "Restart" => 'always',
    "RestartSec" => 5,
    "ExecStart" => [
      '',
      "/usr/bin/dockerd -H fd:// --log-driver=journald"
    ]
  }
}


include_recipe "kubernetes-app::_docker"
include_recipe "kubernetes-app::_static_pods"


[
  node['kubernetes']['srv_path']
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end

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


[
  node['kube_worker']['kubelet']['kubeconfig_path'],
  node['kube_worker']['kube_proxy']['kubeconfig_path']
].each do |d|
  directory ::File.dirname(d) do
    recursive true
    action [:create]
  end
end

file node['kube_worker']['kubelet']['kubeconfig_path'] do
  content node['kube_worker']['kubelet']['kubeconfig'].to_hash.to_yaml
  action :create
end

file node['kube_worker']['kube_proxy']['kubeconfig_path'] do
  content node['kube_worker']['kube_proxy']['kubeconfig'].to_hash.to_yaml
  action :create
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

systemd_unit 'kubelet.service' do
  content node['kube_worker_dummy']['kubelet']['systemd']
  action [:create, :enable, :start]
  subscribes :restart, "kubernetes_ca[ca]", :delayed
end

systemd_unit 'kube-proxy.service' do
  content node['kube_worker']['kube_proxy']['systemd']
  action [:create, :enable, :start]
  subscribes :restart, "kubernetes_ca[ca]", :delayed
end
