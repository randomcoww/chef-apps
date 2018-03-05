services = {}
node['environment_v2']['set'].each_value do |set|
  if set.is_a?(Hash) &&
    set.has_key?('services')

    set['services'].each do |service, c|
      if node['environment_v2']['haproxy'].has_key?(service) &&
        node['environment_v2']['haproxy'][service].has_key?('port')

        bind = node['environment_v2']['haproxy'][service]['port']

        services["frontend #{service}"] = {
          'default_backend' => service,
          'bind' => "*:#{bind}",
          'maxconn' => 2000
        }

        services["backend #{service}"] = {
          "{{range $nodename, $n := $.Nodes}}{{if $n.Address}}server" => "{{$nodename}} {{$n.Address}}:#{c['port']} check{{end}}
  {{end}}"
        }
      end
    end
  end
end


haproxy_config = HaproxyHelper::ConfigGenerator.generate_from_hash({
  'global' => {
    # 'user' => 'haproxy',
    # 'group' => 'haproxy',
    'log' => '127.0.0.1 local0',
    'log-tag' => 'haproxy',
    'quiet' => nil,
    'stats' => [
      # 'socket /var/run/haproxy.sock user haproxy group haproxy',
      'socket /var/run/haproxy.sock',
      'timeout 2m'
    ],
    'maxconn' => 1024,
    # 'master-worker' => 'exit-on-failure',
    'pidfile' => '/var/run/haproxy.pid'
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
  }
}.merge(services))


haproxy_template = <<-EOF
{{range $name, $s := $.Services}}{{range $portname, $p := $s.Ports}}frontend {{$name}}_{{$portname}}
  default_backend {{$name}}_{{$portname}}
  bind *:{{$p.TargetPort}}
  maxconn 2000
backend {{$name}}_{{$portname}}
  {{range $nodename, $n := $.Nodes}}{{if $n.Address}}server {{$nodename}} {{$n.Address}}:{{$p.NodePort}} check{{end}}
  {{end}}
{{end}}{{end}}
EOF

# node.default['kube_manifests']['haproxy']['config'] = haproxy_config
node.default['kube_manifests']['haproxy']['template'] = [haproxy_config, haproxy_template].join($/)
node.default['kube_manifests']['haproxy']['config_path'] = '/etc/haproxy/haproxy.cfg'
node.default['kube_manifests']['haproxy']['pid_path'] = '/run/haproxy.pid'
