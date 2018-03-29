services = {}

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
frontend apiserver
  default_backend apiserver
  bind *:#{node['environment_v2']['port']['kube-master']}
  maxconn 2000
backend apiserver
  {{range $nodename, $n := $.Nodes}}{{if $n.Address}}server {{$nodename}} {{$n.Address}}:#{node['environment_v2']['port']['kube-master-internal']} check{{end}}
  {{end}}
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
