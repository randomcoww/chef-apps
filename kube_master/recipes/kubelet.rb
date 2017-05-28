directory ::File.dirname(node['kube_master']['kubelet']['kubeconfig_path']) do
  recursive true
  action [:create]
end

file node['kube_master']['kubelet']['kubeconfig_path'] do
  content node['kube_master']['kubelet']['kubeconfig'].to_hash.to_yaml
  action :create
end

systemd_unit 'kubelet.service' do
  content node['kube_master']['kubelet']['systemd']
  action [:create, :enable, :start]
end
