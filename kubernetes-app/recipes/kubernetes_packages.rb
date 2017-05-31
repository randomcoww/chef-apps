[
  node['kubernetes']['srv_path'],
  node['kubernetes']['manifests_path']
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end


## kubelet
remote_file node['kubernetes']['kubelet']['binary_path'] do
  source node['kubernetes']['kubelet']['remote_file']
  mode '0750'
  action :create_if_missing
end

## kube-proxy
remote_file node['kubernetes']['kube_proxy']['binary_path'] do
  source node['kubernetes']['kube_proxy']['remote_file']
  mode '0750'
  action :create_if_missing
end

## kubectl
remote_file node['kubernetes']['kubectl']['binary_path'] do
  source node['kubernetes']['kubectl']['remote_file']
  mode '0750'
  action :create_if_missing
end
