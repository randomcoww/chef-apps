include_recipe "kubelet-app::_docker"
include_recipe "kubelet-app::_static_pods"

[
  'kubelet',
].each do |e|
  remote_file node['kubernetes'][e]['binary_path'] do
    source node['kubernetes'][e]['remote_file']
    mode '0750'
    action :create_if_missing
  end
end

## kubelet
systemd_unit 'kubelet.service' do
  content node['kubernetes']['kubelet']['systemd']
  action [:create, :enable, :start]
end
