node.default['mysql_credentials']['root']['password'] = Dbag::Keystore.new(
    'deploy_config', 'mysql-cluster'
  ).get_or_create('root_password', SecureRandom.hex)

node.default['mysql_credentials']['kea']['database'] = 'Kea'
node.default['mysql_credentials']['kea']['username'] = 'Keauser'
node.default['mysql_credentials']['kea']['password'] = Dbag::Keystore.new(
    'deploy_config', 'mysql-cluster'
  ).get_or_create('kea_password', SecureRandom.hex)
