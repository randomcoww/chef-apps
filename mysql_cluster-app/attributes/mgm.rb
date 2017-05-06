node.default['mysql_cluster']['mgm']['pkg_names'] = [
  'mysql-cluster-community-management-server',
  'mysql-cluster-community-client'
]

node.default['mysql_cluster']['mgm']['config'] = {
  'ndb_mgmd default' => {
    'datadir' => '/var/lib/mysql-cluster'
  },
  'ndbd default' => {
    'NoOfReplicas' => 2,
    'DataMemory' => '256M',
    'IndexMemory' => '128M',
    'DataDir' => '/var/lib/mysql-cluster'
  },
  'ndb_mgmd' => node['environment_v2']['set']['mysql-mgm']['hosts'].map { |e|
    {
      'hostname' => node['environment_v2']['host'][e]['ip_lan']
    }
  },
  'ndbd' => node['environment_v2']['set']['mysql-ndb']['hosts'].map { |e|
    {
      'hostname' => node['environment_v2']['host'][e]['ip_lan']
    }
  },
  'mysqld' => node['environment_v2']['set']['mysql-ndb']['hosts'].map { |e|
    {
      'hostname' => node['environment_v2']['host'][e]['ip_lan']
    }
  }
}
