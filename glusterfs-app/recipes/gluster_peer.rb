node.default['glusterfs']['host_set'] = 'gluster'
include_recipe 'gluster-app::_peer'
