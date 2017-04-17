chef_gem 'cassandra-driver' do
  action :upgrade
end

docker_image 'cassandra' do
  action :pull_if_missing
end

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
  action :run
end

cassandra_query 'create_keyspace' do
  query node['cql']['kea_leases']['create_keyspace_query']
  keyspace 'system_schema'
  timeout 120
  ignore_already_exists true
  action :run
end

node['cql']['kea_leases']['create_tables_query'].each do |k|
  cassandra_query k do
    query k
    keyspace node['cql']['kea_leases']['keyspace_name']
    timeout 120
    ignore_already_exists true
    action :run
  end
end
