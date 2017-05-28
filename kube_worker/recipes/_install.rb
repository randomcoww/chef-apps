include_recipe "kube_worker::flannel"
include_recipe "kube_worker::docker"

[
  node['kube_worker']['srv_path'],
  node['kube_worker']['manifests_path']
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end


kubernetes_ca 'ca' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cert_path node['kube_worker']['ca_path']
  action :create
end

kubernetes_node_cert 'worker' do
  data_bag 'deploy_config'
  data_bag_item 'kubernetes_ssl'
  cn "kube-#{node['hostname']}"
  key_path node['kube_worker']['key_path']
  cert_path node['kube_worker']['cert_path']
  alt_names ({
    'IP.1' => node['kube_worker']['node_ip']
  })
  action :create_if_missing
end


# file node['kube_worker']['token_file_path'] do
#   content (node['kube_worker']['tokens'].map.with_index { |kv, i|
#       [kv[1], kv[0], i].join(',')
#     }.join($/))
#   action :create
# end


include_recipe "kube_worker::kubelet"
include_recipe "kube_worker::kube_proxy"
