node_ips = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan'])
node_ip = node_ips.first

etcd_installation 'main' do
  version node['etcd']['main']['version']
  action :create
end

# etcd_service node['hostname'] do
#   data_dir '/var/lib/etcd'
#   service_manager 'systemd'
#
#   initial_cluster_token 'etcd-cluster-1'
#
#   initial_advertise_peer_urls "http://#{node_ip}:2380"
#   listen_peer_urls "http://#{node_ip}:2380"
#   listen_client_urls ["http://#{node_ip}:2379", "http://127.0.0.1:2379"].join(',')
#   advertise_client_urls "http://#{node_ip}:2379"
#   initial_cluster node['environment_v2']['set']['etcd']['hosts'].map { |e|
#       "#{e}=http://#{node['environment_v2']['host'][e]['ip_lan']}:2380"
#     }.join(',')
#   initial_cluster_state 'new'
#
#   action :create
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
  content node['etcd']['main']['bootstrap_systemd']
  action [:create, :enable, :start]
end
