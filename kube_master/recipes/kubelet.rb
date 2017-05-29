remote_file node['kube_master']['kubelet']['binary_path'] do
  source node['kube_master']['kubelet']['remote_file']
  mode '0750'
  action :create_if_missing
end

systemd_unit 'kubelet.service' do
  content node['kube_master']['kubelet']['systemd']
  action [:create, :enable, :start]
  subscribes :restart, "kubernetes_ca[ca]", :delayed
end
