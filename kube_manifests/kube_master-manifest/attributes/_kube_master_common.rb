hosts = node['environment_v2']['set']['kube_master']['hosts']

node.default['kube_manifests']['kube_master']['hosts'] = hosts
node.default['kube_manifests']['kube_master']['host_ips'] = hosts.map { |host|
    node['environment_v2']['host'][host]['ip_lan']
  }
