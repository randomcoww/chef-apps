package node['kea']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[kea-dhcp4-server]", :immediately
end

chef_gem 'mysql2' do
  action :install
  compile_time false
end

## provision mysql

mysql_cluster_sql 'query' do
  queries ([
    %Q{CREATE DATABASE IF NOT EXISTS #{node['mysql-credentials']['kea']['database']}},
    %Q{CREATE USER IF NOT EXISTS '#{node['mysql-credentials']['kea']['username']}'@'%' IDENTIFIED BY '#{node['mysql-credentials']['kea']['password']}';},
    %Q{GRANT ALL PRIVILEGES ON #{node['mysql-credentials']['kea']['database']}.* TO '#{node['mysql-credentials']['kea']['username']}'@'%' WITH GRANT OPTION;}
  ])
  timeout 120
  options ({
    username: 'root',
    password: node['mysql-credentials']['root']['password']
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
    --user="#{node['mysql-credentials']['kea']['username']}" \
    --password="#{node['mysql-credentials']['kea']['password']}" \
    --database="#{node['mysql-credentials']['kea']['database']}" \
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
