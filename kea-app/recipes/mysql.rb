package 'kea-dhcp4-server' do
  action :install
  notifies :stop, "service[kea-dhcp4-server]", :immediately
end

package 'default-libmysqlclient-dev' do
  action :install
end

chef_gem 'mysql2' do
  action :install
  compile_time false
end

## provision mysql

mysql_cluster_sql 'query' do
  queries ([
    %Q{CREATE DATABASE IF NOT EXISTS #{node['mysql_credentials']['kea']['database']}},
    %Q{CREATE USER IF NOT EXISTS '#{node['mysql_credentials']['kea']['username']}'@'%' IDENTIFIED BY '#{node['mysql_credentials']['kea']['password']}';},
    %Q{GRANT ALL PRIVILEGES ON #{node['mysql_credentials']['kea']['database']}.* TO '#{node['mysql_credentials']['kea']['username']}'@'%' WITH GRANT OPTION;}
  ])
  timeout 120
  options ({
    username: 'root',
    password: node['mysql_credentials']['root']['password']
  })
  action :query
end

kea_tables_path = ::File.join(Chef::Config[:file_cache_path], 'kea_database.sql')

cookbook_file kea_tables_path do
  source 'kea_tables.sql'
  notifies :run, "bash[provision_kea_tables]", :immediately
  action :create_if_missing
end

## this may be provisioned by another host and fail

bash "provision_kea_tables" do
  code %Q{mysql \
    --user="#{node['mysql_credentials']['kea']['username']}" \
    --password="#{node['mysql_credentials']['kea']['password']}" \
    --database="#{node['mysql_credentials']['kea']['database']}" \
    < #{kea_tables_path}}
  ignore_failure true
  action :nothing
end

## start kea

kea_dhcp4_config 'kea-mysql' do
  config node['kea']['mysql']['config']
  action :create
  notifies :restart, "service[kea-dhcp4-server]", :delayed
end

include_recipe "kea::dhcp4_service_mysql"
