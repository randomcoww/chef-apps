chef_gem 'cassandra-driver' do
  action :nothing
end.run_action(:upgrade)

docker_image 'cassandra' do
  action :nothing
end.run_action(:pull_if_missing)

env = {
  'CASSANDRA_LISTEN_ADDRESS' => node['cql']['kea_leases']['node_ip'],
  'CASSANDRA_BROADCAST_ADDRESS' => node['cql']['kea_leases']['node_ip'],
  'CASSANDRA_CLUSTER_NAME' => node['cql']['kea_leases']['cluster_name'],
  'CASSANDRA_SEEDS' => node['cql']['kea_leases']['seeds'].join(','),
  'CASSANDRA_DC' => node['cql']['kea_leases']['datacenter'],
  'CASSANDRA_ENDPOINT_SNITCH' => 'GossipingPropertyFileSnitch'
}

docker_container 'cassandra_kea_leases' do
  repo 'cassandra'
  network_mode 'host'
  env (env.map { |i, j| [i, j].join('=') })
  restart_policy 'unless-stopped'
  action :nothing
end.run_action(:run)

c = CassandraCluster.new({}, 120)

## create keyspace
Chef::Log.info(node['cql']['kea_leases']['create_keyspace_query'])
c.query('system_schema', node['cql']['kea_leases']['create_keyspace_query'])

## create tables
node['cql']['kea_leases']['create_tables_query'].each do |k|
  Chef::Log.info(k)
  c.query(node['cql']['kea_leases']['keyspace_name'], k)
end

## remove dead nodes
c.cluster.each_host do |h|
  if h.down?
    Chef::Log.info("Remove node: #{h.id}")

    docker_exec "Remove node: #{h.id}" do
      container 'cassandra_kea_leases'
      command ["nodetool", "removenode", h.id]
    end
  end
end
