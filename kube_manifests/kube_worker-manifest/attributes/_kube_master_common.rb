hosts = node['environment_v2']['set']['kube-worker']['hosts']

node.default['kube_manifests']['kube_worker']['hosts'] = hosts
node.default['kube_manifests']['kube_worker']['host_ips'] = hosts.map { |host|
    node['environment_v2']['host'][host]['ip_lan']
  }
