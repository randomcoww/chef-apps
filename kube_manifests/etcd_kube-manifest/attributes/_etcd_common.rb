hosts = node['environment_v2']['set']['etcd-kube']['hosts']

node.default['kube_manifests']['etcd_kube']['hosts'] = hosts
