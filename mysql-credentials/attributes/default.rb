node.default['mysql-credentials']['root']['password'] = Dbag::Keystore.new(
    'deploy_config', 'mysql-cluster'
  ).get_or_create('root_password', SecureRandom.hex)

node.default['mysql-credentials']['kea']['database'] = 'Kea'
node.default['mysql-credentials']['kea']['username'] = 'Keauser'
node.default['mysql-credentials']['kea']['password'] = Dbag::Keystore.new(
    'deploy_config', 'mysql-cluster'
  ).get_or_create('kea_password', SecureRandom.hex)
