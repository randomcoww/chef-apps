lan_domain = [
  node['environment_v2']['domain']['host_lan'],
  node['environment_v2']['domain']['top']
].join('.')


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
          "{{range $node, $host := $.Nodes}}server" => "{{$node.NodeName}} {{$host.InternalIP}}:#{c['port']} check
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
    'master-worker' => 'exit-on-failure',
    'pidfile' => '/var/run/haproxy.pid'
  },
  # 'resolvers default' => {
  #   'nameserver' => "vip #{node['environment_v2']['set']['ns']['vip_lan']}:53",
  #   'resolve_retries' => 3
  # },
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

# haproxy_template = [
#   '{{range $index, $element := .}}{{if $element.NodePort}}',
#   HaproxyHelper::ConfigGenerator.generate_from_hash({
#     'frontend {{$index.ServiceName}}_{{$index.PortName}}' => {
#       'default_backend' => '{{$index.ServiceName}}_{{$index.PortName}}',
#       'bind' => '*:{{$element.Port}}',
#       'maxconn' => 2000
#     },
#     'backend {{$index.ServiceName}}_{{$index.PortName}}' => {
#       'server' => node['environment_v2']['set']['kube-master']['hosts'].map { |e|
#         "#{e} #{[e, lan_domain].join('.')}:{{$element.NodePort}} init-addr libc,none resolvers default"
#       }
#     }
#   }),
#   '{{end}}{{end}}'
# ].join($/)


haproxy_template = <<-EOF
{{range $service, $ports := $.Services}}{{if $ports.NodePort}}
frontend {{$service.ServiceName}}_{{$service.PortName}}
  default_backend {{$service.ServiceName}}_{{$service.PortName}}
  bind *:{{$ports.Port}}
  maxconn 2000
backend {{$service.ServiceName}}_{{$service.PortName}}
  {{range $node, $host := $.Nodes}}server {{$node.NodeName}} {{$host.InternalIP}}:{{$ports.NodePort}} check
  {{end}}
{{end}}{{end}}
EOF

# node.default['kube_manifests']['haproxy']['config'] = haproxy_config
node.default['kube_manifests']['haproxy']['template'] = [haproxy_config, haproxy_template].join($/)
node.default['kube_manifests']['haproxy']['config_path'] = '/etc/haproxy/haproxy.cfg'
node.default['kube_manifests']['haproxy']['pid_path'] = '/run/haproxy.pid'
