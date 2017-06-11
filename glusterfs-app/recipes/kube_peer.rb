node.default['glusterfs']['host_set'] = 'kube-worker'
include_recipe 'gluster-app::_peer'
