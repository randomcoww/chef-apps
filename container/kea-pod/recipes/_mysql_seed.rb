kea_mysql_seed 'seed' do
  url 'https://raw.githubusercontent.com/isc-projects/kea/master/src/share/database/scripts/mysql/dhcpdb_create.mysql'
  options ({
    username: node['mysql_credentials']['kea']['username'],
    password: node['mysql_credentials']['kea']['password'],
    database: node['mysql_credentials']['kea']['database'],
    host: '127.0.0.1',
    port: 3306
  })
  action :create
end
