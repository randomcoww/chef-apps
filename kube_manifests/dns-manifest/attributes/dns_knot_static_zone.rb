a_records = []

node['environment_v2']['host'].each do |hostname, d|
  if !d['ip_lan'].nil?
    a_records << {
        name: [hostname, node['environment_v2']['domain']['host_lan']].join('.'),
        ttl: 300,
        host: d['ip_lan']
      }
  end

  if !d['ip_store'].nil?
    a_records << {
        name: [hostname, node['environment_v2']['domain']['host_store']].join('.'),
        ttl: 300,
        host: d['ip_store']
      }
  end
end

node['environment_v2']['set'].each do |set, d|
  if !d['vip_lan'].nil?
    a_records << {
        name: [set, node['environment_v2']['domain']['vip_lan']].join('.'),
        ttl: 300,
        host: d['vip_lan']
      }
  end

  if !d['vip_store'].nil?
    a_records << {
        name: [set, node['environment_v2']['domain']['vip_store']].join('.'),
        ttl: 300,
        host: d['vip_store']
      }
  end
end


node.default['kube_manifests']['dns']['knot_static_zone'] = DnsZoneHelper::ConfigGenerator.generate_from_hash({
  'soa' => {
    name: "#{node['environment_v2']['domain']['top']}.",
    ttl: 300,
    ns: "ns.#{node['environment_v2']['domain']['top']}.",
    email: "root.#{node['environment_v2']['domain']['top']}.",
    sn: 2017010101,
    ref: 28800,
    ret: 14400,
    ex: 604800,
    nx: 86400
  },
  'ns' => {
    name: "#{node['environment_v2']['domain']['top']}.",
    ttl: 300,
    host: "ns.#{node['environment_v2']['domain']['top']}."
  },
  'a' => a_records
})
