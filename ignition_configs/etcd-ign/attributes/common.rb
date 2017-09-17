hosts = node['environment_v2']['set']['etcd']['hosts']

node.default['ignition']['etcd']['hosts'] = hosts
