node.default['ignition']['version'] = '2.1.0'
node.default['ignition']['config_path'] = '/config/ignition'

node.default['ignition']['etcd']['hosts'] = node['environment_v2']['set']['etcd']['hosts']
node.default['ignition']['gateway']['hosts'] = node['environment_v2']['set']['gateway']['hosts']
node.default['ignition']['kube_worker']['hosts'] = node['environment_v2']['set']['kube-worker']['hosts']
node.default['ignition']['kube_master']['hosts'] = node['environment_v2']['set']['kube-master']['hosts']
