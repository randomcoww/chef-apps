hosts = node['environment_v2']['set']['dns']['hosts'] +
  node['environment_v2']['set']['kea']['hosts'] +
  node['environment_v2']['set']['kube-master']['hosts'] +
  node['environment_v2']['set']['kube-worker']['hosts']

node.default['qemu']['generic']['hosts'] = hosts
