node.default['mysql-cluster']['kea']['pkg_names'] = [
  'default-libmysqlclient-dev'
]

node.default['mysql-cluster']['kea']['kea_password'] = Dbag::Keystore.new(
  'deploy_config', 'mysql-cluster'
).get_or_create('kea_password', SecureRandom.hex)

node.default['mysql-cluster']['kea']['database'] = 'Kea'
node.default['mysql-cluster']['kea']['username'] = 'Keauser'

node.default['mysql-cluster']['kea']['root_sql'] = [
  %Q{CREATE DATABASE IF NOT EXISTS #{node['mysql-cluster']['kea']['database']}},
  %Q{CREATE USER IF NOT EXISTS '#{node['mysql-cluster']['kea']['username']}'@'%' IDENTIFIED BY '#{node['mysql-cluster']['kea']['kea_password']}';},
  %Q{GRANT ALL PRIVILEGES ON #{node['mysql-cluster']['kea']['database']}.* TO '#{node['mysql-cluster']['kea']['username']}'@'%' WITH GRANT OPTION;}
]
