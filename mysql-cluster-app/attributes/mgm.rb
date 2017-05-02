node.default['mysql-cluster']['mgm']['pkg_names'] = [
  'mysql-cluster-community-management-server',
  'mysql-cluster-community-client'
]

node.default['mysql-cluster']['mgm']['config'] = {
  'ndb_mgmd default' => {
    'datadir' => '/var/lib/mysql-cluster'
  },
  'ndbd default' => {
    'NoOfReplicas' => 2,
    'DataMemory' => '256M',
    'IndexMemory' => '128M',
    'DataDir' => '/var/lib/mysql-cluster'
  },
  'ndb_mgmd' => [
    {
      'hostname' => node['environment_v2']['host']['mysql-mgm']['ip_lan']
    }
  ],
  'ndbd' => [
    {
      'hostname' => node['environment_v2']['host']['mysql-ndb1']['ip_lan']
    },
    {
      'hostname' => node['environment_v2']['host']['mysql-ndb2']['ip_lan']
    }
  ],
  'mysqld' => [
    {
      'hostname' => node['environment_v2']['host']['mysql-ndb1']['ip_lan']
    },
    {
      'hostname' => node['environment_v2']['host']['mysql-ndb2']['ip_lan']
    }
  ]
}
