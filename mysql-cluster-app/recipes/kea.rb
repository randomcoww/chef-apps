execute "pkg_update" do
  command node['mysql-cluster']['pkg_update_command']
  action :run
end

apt_package node['mysql-cluster']['kea']['pkg_names'] do
  action :install
  options [
    '--no-install-recommends'
  ]
end

chef_gem 'mysql2' do
  action :install
  compile_time false
end

mysql_cluster_sql 'query' do
  queries node['mysql-cluster']['kea']['root_sql']
  timeout 120
  options ({
    username: 'root',
    password: node['mysql-cluster']['api']['root_password']
  })
  action :query
end

kea_tables_path = ::File.join(Chef::Config[:file_cache_path], 'kea_database.sql')

cookbook_file kea_tables_path do
  source 'kea_tables.sql'
  notifies :run, "bash[provision_kea_tables]", :delayed
  action :create_if_missing
end

## this may be provisioned by another host and fail
bash "provision_kea_tables" do
  code %Q{mysql \
    --user="#{node['mysql-cluster']['kea']['username']}" \
    --password="#{node['mysql-cluster']['kea']['kea_password']}" \
    --database="#{node['mysql-cluster']['kea']['database']}" \
    < #{kea_tables_path}}
  ignore_failure true
  action :nothing
end
