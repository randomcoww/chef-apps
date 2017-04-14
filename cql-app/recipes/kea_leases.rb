execute "pkg_update" do
  command node['cql']['pkg_update_command']
  action :run
end

package node['cql']['pkg_names'] do
  action :install
  notifies :stop, "service[cassandra]", :immediately
end

chef_gem 'cassandra-driver' do
  action :upgrade
end

[
  node['cql']['kea_leases']['data_file_directory'],
  node['cql']['kea_leases']['hints_directory'],
  node['cql']['kea_leases']['saved_caches_directory'],
  node['cql']['kea_leases']['commitlog_directory']
].each do |d|
  directory d do
    recursive true
    owner 'cassandra'
    group 'cassandra'
    action :create
  end
end

template '/etc/cassandra/jvm.options' do
  source 'jvm.options.erb'
  variables ({
    replace_address: node['cql']['kea_leases']['node_ip']
  })
  action :create
end

cassandra_config node['cql']['kea_leases']['cluster_name'] do
  config node['cql']['kea_leases']['cassandra_config'].to_hash
  action :create
  notifies :restart, "service[cassandra]", :delayed
end

remote_file node['cql']['kea_leases']['create_tables_cql_path'] do
  source node['cql']['kea_leases']['create_tables_cql']
  action :create_if_missing
  notifies :run, "cassandra_query[create_keyspace]", :delayed
end

cassandra_query 'create_keyspace' do
  query node['cql']['kea_leases']['create_keyspace_query']
  keyspace 'system_schema'
  timeout 60
  ignore_already_exists true
  action :nothing
  notifies :run, "cassandra_query[create_tables]", :immediately
end

cassandra_query 'create_tables' do
  query node['cql']['kea_leases']['create_keyspace_query']
  keyspace node['cql']['kea_leases']['keyspace_name']
  timeout 60
  ignore_already_exists true
  action :nothing
end

include_recipe "cassandra::service"
