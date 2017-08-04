[
  'kubectl',
].each do |e|
  remote_file node['kubernetes'][e]['binary_path'] do
    source node['kubernetes'][e]['remote_file']
    mode '0750'
    action :create_if_missing
  end
end


[
  node['kubernetes']['srv_path'],
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end

## ssl
kubernetes_ca 'ca' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cert_path node['kubernetes']['ca_path']
  action :create
end

kubernetes_admin_cert 'client' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cn "kube-client"
  key_path node['kubernetes']['key_path']
  cert_path node['kubernetes']['cert_path']
  action :create_if_missing
  subscribes :create, "kubernetes_ca[ca]", :immediately
end


directory ::File.dirname(node['kube_client']['kubectl']['kubeconfig_path']) do
  recursive true
  action [:create]
end

file node['kube_client']['kubectl']['kubeconfig_path'] do
  content node['kube_client']['kubectl']['kubeconfig'].to_hash.to_yaml
  action :create
end
