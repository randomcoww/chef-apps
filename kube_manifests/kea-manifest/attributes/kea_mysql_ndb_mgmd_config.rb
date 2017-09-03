node.default['kube_manifests']['kea']['mysql_ndb_mgmd_config'] = MysqlHelper::ConfigGenerator.generate_from_hash({
  'ndb_mgmd default' => {
    'datadir' => '/var/lib/mysql-cluster'
  },
  'ndbd default' => {
    'NoOfReplicas' => 2,
    'DataMemory' => '256M',
    'IndexMemory' => '128M',
    'DataDir' => '/var/lib/mysql-cluster'
  },
  'ndb_mgmd' => node['kube_manifests']['kea']['host_ips'].map.with_index(1) { |ip, index|
    {
      'nodeid' => index,
      'hostname' => ip
    }
  },
  'ndbd' => node['kube_manifests']['kea']['host_ips'].map { |ip|
    {
      'hostname' => ip
    }
  },
  'mysqld' => node['kube_manifests']['kea']['host_ips'].map { |ip|
    {
      'hostname' => ip
    }
  }
})
