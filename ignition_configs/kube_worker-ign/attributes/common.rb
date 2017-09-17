hosts = node['environment_v2']['set']['kube-worker']['hosts']

node.default['ignition']['kube_worker']['hosts'] = hosts
