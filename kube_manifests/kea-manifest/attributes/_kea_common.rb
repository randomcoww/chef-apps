node.default['kube_manifests']['kea']['mysql_data_ips'] = node['environment_v2']['set']['kea-mysql-data']['hosts'].map { |host|
  node['environment_v2']['host'][host]['ip']['store']
}

node.default['kube_manifests']['kea']['mysql_mgm_ips'] = node['environment_v2']['set']['kea-mysql-mgm']['hosts'].map { |host|
  node['environment_v2']['host'][host]['ip']['store']
}

node.default['kube_manifests']['kea']['kea_ips'] = node['environment_v2']['set']['kea']['hosts'].map { |host|
  node['environment_v2']['host'][host]['ip']['store']
}
