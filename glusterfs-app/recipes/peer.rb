package node['glusterfs']['pkg_names'] do
  action :install
  # notifies :stop, "service[glusterfs-server]", :immediately
end


gluster_nodes = node['environment_v2']['set']['gluster']['hosts'].map do |e|
  node['environment_v2']['host'][e]['ip_store']
end

## remove self if included
node_ips = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['store'])
gluster_nodes -= node_ips

glusterfs_peer 'gluster' do
  peer_hosts gluster_nodes
  data_bag node['glusterfs']['data_bag']
  data_bag_item node['glusterfs']['data_bag_item']
  key node_ips.first
  action :create
end
