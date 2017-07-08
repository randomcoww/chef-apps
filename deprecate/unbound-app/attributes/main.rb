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
      "127.0.0.0/8 allow",
      "#{node['environment_v2']['subnet']['lan']} allow",
      "#{node['environment_v2']['subnet']['vpn']} allow"
    ],
    "do-not-query-localhost" => false,
    'local-zone' => [
      'lan nodefault',
    ],
    "private-domain" => [
      "lan",
    ],
    "domain-insecure" => [
      "lan",
    ]
  },
  'remote-control' => {
    'control-enable' => true
  },
  'stub-zone' => [
    {
      'name' => 'lan',
      'stub-addr' => '127.0.0.1@53530'
    }
  ]
}
