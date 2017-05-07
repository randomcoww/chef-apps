etcd_installation 'main' do
  version node['etcd']['main']['version']
  action :create
end

# etcd_service node['hostname'] do
#   data_dir '/var/lib/etcd'
#   service_manager 'systemd'
#
#   initial_cluster_token node['etcd']['main']['environment']['ETCD_INITIAL_CLUSTER_TOKEN']
#   initial_advertise_peer_urls node['etcd']['main']['environment']['ETCD_INITIAL_ADVERTISE_PEER_URLS']
#   listen_peer_urls node['etcd']['main']['environment']['ETCD_LISTEN_PEER_URLS']
#   listen_client_urls node['etcd']['main']['environment']['ETCD_LISTEN_CLIENT_URLS']
#   advertise_client_urls node['etcd']['main']['environment']['ETCD_ADVERTISE_CLIENT_URLS']
#   initial_cluster node['etcd']['main']['environment']['ETCD_INITIAL_CLUSTER']
#   initial_cluster_state node['etcd']['main']['environment']['ETCD_INITIAL_CLUSTER_STATE']
#
#   action :start
# end

user node['etcd']['main']['user'] do
  shell '/bin/false'
  action :create
end

directory node['etcd']['main']['environment']['ETCD_DATA_DIR'] do
  owner node['etcd']['main']['user']
  recursive true
  action :create
end

systemd_unit "etcd.service" do
  content node['etcd']['main']['systemd_unit']
  action [:create, :enable, :start]
end
