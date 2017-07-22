include_recipe "kubelet-app::_docker"
include_recipe "kubelet-app::_static_pods"

remote_file node['kubernetes']['kubelet']['binary_path'] do
  source node['kubernetes']['kubelet']['remote_file']
  mode '0750'
  action :create_if_missing
end

## kubelet
systemd_unit 'kubelet.service' do
  content node['kubernetes']['kubelet']['systemd']
  action [:create, :enable, :start]
end
