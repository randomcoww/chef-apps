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
