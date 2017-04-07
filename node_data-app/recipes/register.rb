dbag = Dbag::Keystore.new(
  node['node_data']['data_bag'],
  node['node_data']['data_bag_item']
)

dbag.put(node['hostname'],
  NodeData::NodeIp.subnet_ipv4(node['environment_v2']['lan_subnet']))
