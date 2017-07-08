nodeip = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan']).first
nodeid = 0

node.default['kea']['mysql_ndb_mgmd']['config'] = MysqlHelper::ConfigGenerator.generate_from_hash({
  'ndb_mgmd default' => {
    'datadir' => '/var/lib/mysql-cluster'
  },
  'ndbd default' => {
    'NoOfReplicas' => 2,
    'DataMemory' => '256M',
    'IndexMemory' => '128M',
    'DataDir' => '/var/lib/mysql-cluster'
  },
  'ndb_mgmd' => node['environment_v2']['set']['kea-mysql-mgmd']['hosts'].map { |e|
    ip = node['environment_v2']['host'][e]['ip_lan']
    nodeid += 1

    if ip == nodeip
      node.default['kubelet']['nodeid'] = nodeid
    end

    {
      'nodeid' => nodeid,
      'hostname' => ip
    }
  },
  'ndbd' => node['environment_v2']['set']['kea-mysql']['hosts'].map { |e|
    {
      # 'nodeid' => (nodeid += 1),
      'hostname' => node['environment_v2']['host'][e]['ip_lan']
    }
  },
  'mysqld' => node['environment_v2']['set']['kea-mysql']['hosts'].map { |e|
    {
      # 'nodeid' => (nodeid += 1),
      'hostname' => node['environment_v2']['host'][e]['ip_lan']
    }
  }
})
