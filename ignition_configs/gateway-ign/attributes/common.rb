hosts = node['environment_v2']['set']['gateway']['hosts']

node.default['ignition']['gateway']['hosts'] = hosts
