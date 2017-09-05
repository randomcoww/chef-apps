hosts = node['environment_v2']['set']['etcd_flannel']['hosts']

node.default['kube_manifests']['etcd_flannel']['hosts'] = hosts
