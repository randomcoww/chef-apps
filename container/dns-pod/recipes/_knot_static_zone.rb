a_records = []
node['environment_v2']['host'].each do |hostname, d|
  if !d['ip_lan'].nil?
    a_records << {
        name: hostname,
        ttl: 300,
        host: d['ip_lan']
      }
  end
end

node['environment_v2']['set'].each do |set, d|
  if !d['vip_lan'].nil?
    a_records << {
        name: set,
        ttl: 300,
        host: d['vip_lan']
      }
  end
end

node.default['kubelet']['knot']['static_zone'] = DnsZoneHelper::ConfigGenerator.generate_from_hash({
  'soa' => {
    name: 'l.lan.',
    ttl: 300,
    ns: 'ns.l.lan.',
    email: 'root.l.lan.',
    sn: 2017010101,
    ref: 28800,
    ret: 14400,
    ex: 604800,
    nx: 86400
  },
  'ns' => {
    name: 'l.lan.',
    ttl: 300,
    host: 'ns.l.lan.'
  },
  'a' => a_records
})
