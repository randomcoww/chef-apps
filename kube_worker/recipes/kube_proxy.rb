remote_file node['kube_worker']['kube_proxy']['binary_path'] do
  source node['kube_worker']['kube_proxy']['remote_file']
  mode '0750'
  action :create_if_missing
end

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
