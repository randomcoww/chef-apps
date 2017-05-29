remote_file node['kube_master']['kubectl']['binary_path'] do
  source node['kube_master']['kubectl']['remote_file']
  mode '0750'
  action :create_if_missing
end
