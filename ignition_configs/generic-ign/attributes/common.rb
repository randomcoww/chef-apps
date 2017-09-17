hosts = node['environment_v2']['set']['dns']['hosts'] +
  node['environment_v2']['set']['kea']['hosts']

node.default['ignition']['generic']['hosts'] = hosts
