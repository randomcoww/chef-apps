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
      'hostname' => node['environment_v2']['mysql-mgm_lan_ip']
    }
  ],
  'ndbd' => [
    {
      'hostname' => node['environment_v2']['mysql-ndb1_lan_ip']
    },
    {
      'hostname' => node['environment_v2']['mysql-ndb2_lan_ip']
    }
  ],
  'mysqld' => [
    {
      'hostname' => node['environment_v2']['mysql-ndb1_lan_ip']
    },
    {
      'hostname' => node['environment_v2']['mysql-ndb2_lan_ip']
    }
  ]
}
