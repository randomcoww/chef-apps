node.default['unbound']['pkg_update_command'] = "apt-get update -qqy"
node.default['unbound']['pkg_names'] = ['unbound']
node.default['unbound']['config'] = {
  'include' => '/etc/unbound/unbound.conf.d/*.conf',
  'server' => {
    'root-hints' => '/etc/unbound/root-hints.conf',
    'num-threads' => 2,
    'do-udp' => true,
    'do-tcp' => true,
    'access-control' => [
      "#{node['environment']['lan_subnet']} allow",
      "#{node['environment']['vpn_subnet']} allow"
    ],
    'private-domain' => "lan."
  },
  'remote-control' => {
    'control-enable' => true
  }
}

node.default['nsd']['rndc_keys']['rndc_keys_data_bag'] = 'deploy_config'
node.default['nsd']['rndc_keys']['rndc_keys_data_bag_item'] = 'rndc_keys'
node.default['nsd']['rndc_keys']['rndc_key_names'] = ['rndc-test-key']
