hosts = node['environment_v2']['set']['kea']['hosts']

node.default['kube_manifests']['kea']['hosts'] = hosts
node.default['kube_manifests']['kea']['host_ips'] = hosts.map { |host|
    node['environment_v2']['host'][host]['ip_lan']
  }
