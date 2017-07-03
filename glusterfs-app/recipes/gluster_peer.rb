node.default['glusterfs']['host_set'] = 'gluster'
include_recipe 'glusterfs-app::_peer'
