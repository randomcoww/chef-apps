hosts = node['environment_v2']['set']['kube-master']['hosts']

node.default['ignition']['kube_master']['hosts'] = hosts
