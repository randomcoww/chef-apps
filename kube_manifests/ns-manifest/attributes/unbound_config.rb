a_records = []
cname_records = []
srv_records = []

node['environment_v2']['host'].each do |hostname, d|
  if d['ip'].is_a?(Hash)

    d['ip'].each do |i, addr|
      a_records << {
          name: [
            hostname,
            node['environment_v2']['domain']['host'],
            node['environment_v2']['domain']['top']
          ].join('.'),
          ttl: 300,
          host: addr
        }
    end
  end
end

node['environment_v2']['set'].each do |hostname, d|
  if d['vip'].is_a?(Hash)

    d['vip'].each do |i, addr|
      a_records << {
          name: [
            hostname,
            node['environment_v2']['domain']['vip'],
            node['environment_v2']['domain']['top']
          ].join('.'),
          ttl: 300,
          host: addr
        }
    end
  end

  if d['services'].is_a?(Hash) &&
    d['hosts'].is_a?(Array)

    d['services'].each do |service, c|

      port = c['port']
      next if !port.is_a?(Integer)

      d['hosts'].each do |hostname|

        srv_records << {
          name: [
            "_#{service}",
            "_#{c['proto'] || 'tcp'}",
            node['environment_v2']['domain']['host'],
            node['environment_v2']['domain']['top']
          ].join('.'),
          ttl: c['ttl'] || 300,
          priority: c['priority'] || 0,
          weight: c['weight'] || 0,
          port: port,
          host: [
            hostname,
            node['environment_v2']['domain']['host'],
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
      "#{node['environment_v2']['domain']['rev']} nodefault",
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
      'name' => node['environment_v2']['domain']['rev'],
      'stub-addr' => "127.0.0.1@53530"
    }
  ]
})
