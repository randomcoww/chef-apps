a_records = []

node['environment_v2']['host'].each do |hostname, d|
  if !d['ip_lan'].nil?
    a_records << {
        name: [
          hostname,
          node['environment_v2']['domain']['host_lan'],
          node['environment_v2']['domain']['top']
        ].join('.'),
        ttl: 300,
        host: d['ip_lan']
      }
  end

  if !d['ip_store'].nil?
    a_records << {
        name: [
          hostname,
          node['environment_v2']['domain']['host_store'],
          node['environment_v2']['domain']['top']
        ].join('.'),
        ttl: 300,
        host: d['ip_store']
      }
  end
end

node['environment_v2']['set'].each do |set, d|
  if !d['vip_lan'].nil?
    a_records << {
        name: [
          set,
          node['environment_v2']['domain']['vip_lan'],
          node['environment_v2']['domain']['top']
        ].join('.'),
        ttl: 300,
        host: d['vip_lan']
      }
  end

  if !d['vip_store'].nil?
    a_records << {
        name: [
          set,
          node['environment_v2']['domain']['vip_store'],
          node['environment_v2']['domain']['top']
        ].join('.'),
        ttl: 300,
        host: d['vip_store']
      }
  end
end

## etcd discovery records
srv_records = []

if node['environment_v2']['set'].has_key?('etcd')
  node['environment_v2']['set']['etcd']['hosts'].each do |hostname|

    srv_records << {
      name: [
        '_etcd-server',
        '_tcp',
        node['environment_v2']['domain']['host_lan'],
        node['environment_v2']['domain']['top']
      ].join('.'),
      ttl: 300,
      priority: 0,
      weight: 0,
      port: 2380,
      host: [
        hostname,
        node['environment_v2']['domain']['host_lan'],
        node['environment_v2']['domain']['top']
      ].join('.')
    }

    srv_records << {
      name: [
        '_etcd-client',
        '_tcp',
        node['environment_v2']['domain']['host_lan'],
        node['environment_v2']['domain']['top']
      ].join('.'),
      ttl: 300,
      priority: 0,
      weight: 0,
      port: 2379,
      host: [
        hostname,
        node['environment_v2']['domain']['host_lan'],
        node['environment_v2']['domain']['top']
      ].join('.')
    }
  end
end


node.default['kube_manifests']['dns']['unbound_config'] = NsdResourceHelper::ConfigGenerator.generate_from_hash({
  'server' => {
    'interface-automatic' => true,
    'interface' => '0.0.0.0',
    'num-threads' => 2,
    'do-ip6' => false,
    'do-udp' => true,
    'do-tcp' => true,
    'access-control' => [
      '0.0.0.0/0 allow'
    ],
    "do-not-query-localhost" => false,
    'local-data' => DnsZoneHelper::ConfigGenerator.generate_from_hash({
      'a' => a_records,
      'srv' => srv_records
    }).map { |r| %Q{"#{r}"} }
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
