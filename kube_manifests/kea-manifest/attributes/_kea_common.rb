node.default['kube_manifests']['kea']['host_ips'] = node['environment_v2']['set']['kea']['hosts'].map { |host|
  node['environment_v2']['host'][host]['ip']['store']
}
