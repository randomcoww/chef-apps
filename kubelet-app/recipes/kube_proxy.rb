remote_file node['kubernetes']['kube_proxy']['binary_path'] do
  source node['kubernetes']['kube_proxy']['remote_file']
  mode '0750'
  action :create_if_missing
end

systemd_unit 'kube-proxy.service' do
  content node['kubernetes']['kube_proxy']['systemd']
  action [:create, :enable, :start]
end
