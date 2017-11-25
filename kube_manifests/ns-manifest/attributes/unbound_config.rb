a_records = []
cname_records = []
srv_records = []

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

  if !d['alias'].nil? &&
    d['hosts'].is_a?(Array)

    d['hosts'].each do |hostname|
      cname_records << {
        name: [
          d['alias'],
          node['environment_v2']['domain']['vip_lan'],
          node['environment_v2']['domain']['top']
        ].join('.'),
        ttl: 300,
        host: [
          hostname,
          node['environment_v2']['domain']['host_lan'],
          node['environment_v2']['domain']['top']
        ].join('.')
      }
    end
  end

  if d['services'].is_a?(Hash)
    d['services'].each do |service, c|
      d['hosts'].each do |host|

        srv_records << {
          name: [
            "_#{service}",
            "_#{c['proto']}",
            node['environment_v2']['domain']['host_lan'],
            node['environment_v2']['domain']['top']
          ].join('.'),
          ttl: c["ttl"] || 300,
          priority: 0,
          weight: 0,
          port: c["port"],
          host: [
            host,
            node['environment_v2']['domain']['host_lan'],
            node['environment_v2']['domain']['top']
          ].join('.')
        }
      end
    end
  end
end


node.default['kube_manifests']['ns']['unbound_config'] = NsdResourceHelper::ConfigGenerator.generate_from_hash({
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
      'cname' => cname_records,
      'srv' => srv_records
    }).map { |r| %Q{"#{r}"} },
    'local-zone' => [
      "#{node['environment_v2']['domain']['top']} nodefault",
      "#{node['environment_v2']['domain']['rev_lan']} nodefault",
    ],
    "private-domain" => [
      node['environment_v2']['domain']['top'],
    ],
    "domain-insecure" => [
      node['environment_v2']['domain']['top'],
    ]
  },
  'remote-control' => {
    'control-enable' => true
  },
  'stub-zone' => [
    {
      'name' => node['environment_v2']['domain']['top'],
      'stub-addr' => "127.0.0.1@53530"
    },
    {
      'name' => node['environment_v2']['domain']['rev_lan'],
      'stub-addr' => "127.0.0.1@53530"
    }
  ]
})
