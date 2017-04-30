node.default['mysql-cluster']['api']['pkg_names'] = ['mysql-cluster-community-server']

node.default['mysql-cluster']['api']['config'] = {
  'mysqld' => {
    'ndbcluster' => nil,
    'default_storage_engine' => 'ndbcluster',
    'ndb-connectstring' => [
      node['environment_v2']['mysql-mgm_lan_ip']
    ].join(','),
    'bind-address' => '0.0.0.0'
  }
}
