kea_mysql_seed 'seed' do
  url node['kea']['dhcp4_mysql']['create_tables_sql_source']
  timeout 300
  options ({
    username: node['mysql_credentials']['kea']['username'],
    password: node['mysql_credentials']['kea']['password'],
    database: node['mysql_credentials']['kea']['database'],
    host: '127.0.0.1',
    port: 3306
  })
  action :create
end
