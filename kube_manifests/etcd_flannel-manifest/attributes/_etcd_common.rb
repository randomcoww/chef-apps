hosts = node['environment_v2']['set']['etcd-flannel']['hosts']

node.default['kube_manifests']['etcd_flannel']['hosts'] = hosts
