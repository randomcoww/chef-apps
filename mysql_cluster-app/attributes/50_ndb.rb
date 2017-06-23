node.default['mysql_cluster']['ndb']['pkg_names'] = ['mysql-cluster-community-data-node']

node.default['mysql_cluster']['ndb']['options'] = {
  'ndb-connectstring' => [
    node['environment_v2']['host']['mysql-mgm']['ip_lan']
  ].join(',')
}
