node.default['glusterfs']['host_set'] = 'kube-worker'
include_recipe 'glusterfs-app::_peer'
