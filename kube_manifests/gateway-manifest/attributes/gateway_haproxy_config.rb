services = {}

lan_domain = [
  node['environment_v2']['domain']['host_lan'],
  node['environment_v2']['domain']['top']
].join('.')

node['environment_v2']['service'].each do |name, config|
  next if !config.has_key?('sets')

  services["frontend #{name}"] = {
    'default_backend' => name,
    'bind' => "*:#{config['bind']}",
    'maxconn' => 2000
  }

  backend = []
  config['sets'].each do |set, port|
    node['environment_v2']['set'][set]['hosts'].each do |host|
      backend << "#{host} #{[host, lan_domain].join('.')}:#{port} check port #{port} init-addr libc,none resolvers default"
    end
  end

  services["backend #{name}"] = {
    "server" => backend
  }
end

node.default['kube_manifests']['gateway']['haproxy_config'] = HaproxyHelper::ConfigGenerator.generate_from_hash({
  'global' => {
    'user' => 'haproxy',
    'group' => 'haproxy',
    'log' => '127.0.0.1 local0',
    'log-tag' => 'haproxy',
    'daemon' => nil,
    'quiet' => nil,
    'stats' => [
      'socket /var/run/haproxy.sock user haproxy group haproxy',
      'timeout 2m'
    ],
    'maxconn' => 1024,
    'pidfile' => '/var/run/haproxy.pid'
  },
  'resolvers default' => {
    'nameserver' => "dns1 127.0.0.1:53",
    'resolve_retries' => 3
  },
  'defaults' => {
    'timeout' => [
      'connect 5000ms',
      'client 10000ms',
      'server 10000ms'
    ],
    'log' => 'global',
    'mode' => 'tcp',
    'balance' => 'roundrobin',
    'option' => [
      'dontlognull',
      'redispatch'
    ],
    'stats' => 'uri /haproxy-status'
  }
}.merge(services))
