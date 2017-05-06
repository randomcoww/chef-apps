haproxy_install 'package' do
  action :create
end

haproxy_config_global 'lb' do
  log "127.0.0.1 local0"
  maxconn 1024
end

haproxy_config_defaults 'lb' do
  balance "roundrobin"
  log 'global'
  mode 'tcp'
  retries 3
  option ([
    'dontlognull',
    'redispatch'
  ])
  timeout ({
    connect: '5000ms',
    client: '10000ms',
    server: '10000ms'
  })
end

haproxy_frontend 'mysql' do
  bind "*:3306"
  default_backend "mysql"
end

haproxy_backend 'mysql' do
  server (node['environment_v2']['set']['mysql-ndb']['hosts'].map.with_index { |e, i|
    "mysql#{i} #{node['environment_v2']['host'][e]['ip_lan']}:3306 check"
  })
end
