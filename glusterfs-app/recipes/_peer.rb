package node['glusterfs']['pkg_names'] do
  action :install
  notifies :stop, "service[glusterfs-server]", :immediately
end


gluster_nodes = node['environment_v2']['set'][node['glusterfs']['host_set']]['hosts'].map do |e|
  node['environment_v2']['host'][e]['ip_store']
end

## remove self if included
node_ips = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['store'])
gluster_nodes -= node_ips


## write glusterd info
glusterfs_glusterd_info 'glusterd.info' do
  data_bag node['glusterfs']['data_bag']
  data_bag_item node['glusterfs']['data_bag_item']
  key node_ips.first
  action [:create, :save_if_missing]
  # notifies :restart, "service[glusterfs-server]", :delayed
  notifies :send, "glusterfs_peer_probe[gluster]", :delayed
end

glusterfs_peer_probe 'gluster' do
  peer_host gluster_nodes.first
  action :nothing
  notifies :start, "service[glusterfs-server]", :before
  notifies :restart, "service[glusterfs-server]", :delayed
end

include_recipe "glusterfs::service"
