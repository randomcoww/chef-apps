dbag = Dbag::Keystore.new('deploy_config', 'rndc_keys')
node.default['knot']['main']['update_key'] = dbag.get_or_create('update_key', SecureRandom.base64)
node.default['knot']['main']['storage'] = ::File.join(Chef::Config[:file_cache_path], 'knot')
node.default['knot']['main']['user'] = 'knot'
node.default['knot']['main']['group'] = 'knot'

node.default['knot']['main']['config'] = {
  'server' => {
    "listen" => "0.0.0.0@53530",
    "user" => "#{node['knot']['main']['user']}:#{node['knot']['main']['group']}"
  },
  'log' => [
    {
      'target' => 'syslog',
      'any' => 'info'
    }
  ],
  'template' => [
    {
      'id' => 'default',
      'storage' => node['knot']['main']['storage']
    }
  ],
  'key' => [
    {
      'id' => 'update_key',
      'algorithm' => 'hmac-sha512',
      'secret' => node['knot']['main']['update_key']
    }
  ],
  'acl' => [
    {
      'id' => 'update_acl',
      'key' => 'update_key',
      'action' => 'update'
    }
  ],
  'zone' => [
    {
      'domain' => 'l.lan',
      # 'storage' => ::File.join(Chef::Config[:file_cache_path], 'knot'),
      'file' => 'l.lan',
    },
    {
      'domain' => 'l.lan',
      # 'storage' => ::File.join(Chef::Config[:file_cache_path], 'knot'),
      'file' => 'l.lan',
      'acl' => 'update_acl'
    }
  ]
}
