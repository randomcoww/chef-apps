node.default['unbound']['pkg_update_command'] = "apt-get update -qqy"
node.default['unbound']['pkg_names'] = ['unbound']

node.default['unbound']['main']['config'] = {
  'include' => '/etc/unbound/unbound.conf.d/*.conf',
  'server' => {
    'interface-automatic' => true,
    'root-hints' => '/etc/unbound/root-hints.conf',
    'interface' => '0.0.0.0',
    'num-threads' => 2,
    'do-udp' => true,
    'do-tcp' => true,
    'access-control' => [
      "#{node['environment']['lan_subnet']} allow",
      "#{node['environment']['vpn_subnet']} allow"
    ],
    'private-domain' => "lan.",
    "do-not-query-localhost" => false,
    'local-zone' => [
      'static.lan nodefault'
    ],
    "private-domain" => [
      "static.lan"
    ],
    "domain-insecure" => [
      "static.lan"
    ]
  },
  'remote-control' => {
    'control-enable' => true
  },
  'stub-zone' => [
    {
      'name' => 'static.lan',
      'stub-addr' => '127.0.0.1@53530'
    }
  ]
}

node.default['nsd']['main']['rndc_keys_data_bag'] = 'deploy_config'
node.default['nsd']['main']['rndc_keys_data_bag_item'] = 'rndc_keys'
node.default['nsd']['main']['rndc_key_names'] = ['rndc-test-key']
