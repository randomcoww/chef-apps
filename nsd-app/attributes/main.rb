node.default['nsd']['main']['rndc_keys_data_bag'] = 'deploy_config'
node.default['nsd']['main']['rndc_keys_data_bag_item'] = 'rndc_keys'
node.default['nsd']['main']['rndc_key_names'] = ['rndc-test-key']

node.default['nsd']['main']['git_repo'] = "https://github.com/randomcoww/nsd-config.git"
node.default['nsd']['main']['git_branch'] = "master"
node.default['nsd']['main']['release_path'] = ::File.join(Chef::Config[:file_cache_path], 'nsd')
node.default['nsd']['main']['zone_options'] = {
  'zones' => {
  }
}

node.default['nsd']['main']['config'] = {
  'include' => '/etc/nsd/nsd.conf.d/*.conf',
  'server' => {
    "do-ip4" => "yes",
    "ip-address" => "0.0.0.0",
    "port" => 53530,
    "username" => "nsd",
    "hide-version" => true,
    "zonesdir" => node['nsd']['main']['release_path']
  },
  'remote-control' => {
    'control-enable' => true
  }
}
