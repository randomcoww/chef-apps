node.default['kube_manifests']['kea']['host_ips'] = node['kube_manifests']['kea']['hosts'].map { |host|
  node['environment_v2']['host'][host]['ip_lan']
}
