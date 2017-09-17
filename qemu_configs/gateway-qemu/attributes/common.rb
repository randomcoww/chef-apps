hosts = node['environment_v2']['set']['gateway']['hosts']

node.default['qemu']['gateway']['hosts'] = hosts
