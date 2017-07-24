[
  'kube_proxy',
].each do |e|
  remote_file node['kubernetes'][e]['binary_path'] do
    source node['kubernetes'][e]['remote_file']
    mode '0750'
    action :create_if_missing
  end
end

systemd_unit 'kube-proxy.service' do
  content node['kubernetes']['kube_proxy']['systemd']
  action [:create, :enable, :start]
end
