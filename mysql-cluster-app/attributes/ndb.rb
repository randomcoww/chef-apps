node.default['mysql-cluster']['ndb']['pkg_names'] = ['mysql-cluster-community-data-node']

node.default['mysql-cluster']['ndb']['options'] = {
  'ndb-connectstring' => [
    node['environment_v2']['mysql-mgm_lan_ip']
  ].join(',')
}
