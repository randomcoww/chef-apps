node.default['kube_worker']['haproxy']['config_path'] = '/etc/haproxy/haproxy.cfg'
node.default['kube_worker']['haproxy']['pid_path'] = '/var/run/haproxy.pid'

backend = {}
node['environment_v2']['set']['kube-master']['hosts'].each do |host|
  backend["server #{host}"] = "#{node['environment_v2']['host'][host]['ip']['store']}:#{node['environment_v2']['port']['controller']} check"
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
    'pidfile' => node['kube_worker']['haproxy']['pid_path']
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
  },
  'frontend controller' => {
    'default_backend' => 'controller',
    'bind' => "*:#{node['environment_v2']['port']['controller']}",
    'maxconn' => 2000
  },
  'backend controller' => backend
})

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

# node.default['kube_worker']['haproxy']['config'] = haproxy_config
node.default['kube_worker']['haproxy']['template'] = [haproxy_config, haproxy_template].join($/)
