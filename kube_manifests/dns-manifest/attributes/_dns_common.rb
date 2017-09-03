hosts = node['environment_v2']['set']['dns']['hosts']

node.default['kube_manifests']['dns']['hosts'] = hosts
node.default['kube_manifests']['dns']['host_ips'] = hosts.map { |host|
    node['environment_v2']['host'][host]['ip_lan']
  }
