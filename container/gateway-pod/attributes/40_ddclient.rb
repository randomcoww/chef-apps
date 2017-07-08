dbag = Dbag::Keystore.new('deploy_config', 'ddclient')
node.default['kubelet']['ddclient']['config'] = DdclientHelper::ConfigGenerator.generate_from_hash(dbag.get('freedns'))
