dbag = Dbag::Keystore.new('deploy_config', 'rndc_keys')

node.default['kubelet']['knot']['config'] = KnotHelper::ConfigGenerator.generate_from_hash({
  'server' => {
    "listen" => "0.0.0.0@53530"
  },
  # 'key' => [
  #   {
  #     'id' => 'update_key',
  #     'algorithm' => 'hmac-sha512',
  #     'secret' => dbag.get_or_create('update_key', SecureRandom.base64)
  #   }
  # ],
  # 'acl' => [
  #   {
  #     'id' => 'update_acl',
  #     'key' => 'update_key',
  #     'action' => 'update'
  #   }
  # ]
})
