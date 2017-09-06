hosts = node['environment_v2']['set']['gateway']['hosts']

node.default['kube_manifests']['gateway']['hosts'] = hosts
