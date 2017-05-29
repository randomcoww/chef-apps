remote_file node['kube_master']['kube_proxy']['binary_path'] do
  source node['kube_master']['kube_proxy']['remote_file']
  mode '0750'
  action :create_if_missing
end

systemd_unit 'kube-proxy.service' do
  content node['kube_master']['kube_proxy']['systemd']
  action [:create, :enable, :start]
  subscribes :restart, "kubernetes_ca[ca]", :delayed
end
