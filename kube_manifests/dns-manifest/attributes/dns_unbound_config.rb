node.default['kube_manifests']['dns']['unbound_config'] = NsdResourceHelper::ConfigGenerator.generate_from_hash({
  'server' => {
    'interface-automatic' => true,
    'interface' => '0.0.0.0',
    'num-threads' => 2,
    'do-ip6' => false,
    'do-udp' => true,
    'do-tcp' => true,
    'access-control' => [
      # "127.0.0.0/8 allow",
      # "#{node['environment_v2']['subnet']['lan']} allow",
      '0.0.0.0/0 allow'
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
})
