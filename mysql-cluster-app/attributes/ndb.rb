node.default['mysql-cluster']['ndb']['pkg_names'] = ['mysql-cluster-community-data-node']

node.default['mysql-cluster']['ndb']['options'] = {
  'ndb-connectstring' => [
    node['environment_v2']['host']['mysql-mgm']['ip_lan']
  ].join(',')
}
