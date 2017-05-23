node.default['kubernetes']['node_ip'] = NodeData::NodeIp.subnet_ipv4(node['environment_v2']['subnet']['lan']).first
