remote_file node['kube_worker']['kubelet']['binary_path'] do
  source node['kube_worker']['kubelet']['remote_file']
  mode '0750'
  action :create_if_missing
end

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
