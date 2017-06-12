def create_tables_sql
  create_tables_sql ||= open(node['kea']['dhcp4_mysql']['create_tables_sql'])
end


package 'default-libmysqlclient-dev' do
  action :install
end

chef_gem 'mysql2' do
  action :install
  compile_time false
end


## provision mysql

mysql_cluster_sql 'create_db' do
  queries ([
    %Q{CREATE DATABASE IF NOT EXISTS #{node['mysql_credentials']['kea']['database']};},
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


## provision tables

mysql_cluster_sql 'create_tables' do
  queries lazy {
    lines = []
      ::File.read(node['kea']['dhcp4_mysql']['create_tables_sql_file']).each_line do |e|
        ## remove comments
        e.gsub!(/\s*#.*?$/, '')
        e.gsub!(/\s*--.*?$/, '')

        e.chomp!
        e.strip!
        next if e.empty?

        e.gsub!('INNODB', 'NDBCLUSTER')
        lines << e
      end

      lines.join(' ').split(';')
    }
  timeout 120
  ignore_errors true
  options ({
    username: node['mysql_credentials']['kea']['username'],
    password: node['mysql_credentials']['kea']['password'],
    database: node['mysql_credentials']['kea']['database']
  })
  action :nothing
end

directory ::File.dirname(node['kea']['dhcp4_mysql']['create_tables_sql_file']) do
  recursive true
end

remote_file node['kea']['dhcp4_mysql']['create_tables_sql_file'] do
  source node['kea']['dhcp4_mysql']['create_tables_sql_source']
  action :create_if_missing
  notifies :query, "mysql_cluster_sql[create_tables]", :immediately
end
