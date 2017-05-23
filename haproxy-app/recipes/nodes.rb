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
  server (node['environment_v2']['set']['mysql-ndb']['hosts'].map { |e|
    "#{e} #{node['environment_v2']['host'][e]['ip_lan']}:3306 check"
  })
end


haproxy_frontend 'kube_master_8080' do
  bind "*:8080"
  default_backend "kube_master_8080"
end

haproxy_backend 'kube_master_8080' do
  server (node['environment_v2']['set']['kube_master']['hosts'].map { |e|
    "#{e} #{node['environment_v2']['host'][e]['ip_lan']}:8080 check"
  })
end

haproxy_frontend 'kube_master_443' do
  bind "*:443"
  default_backend "kube_master_443"
end

haproxy_backend 'kube_master_443' do
  server (node['environment_v2']['set']['kube_master']['hosts'].map { |e|
    "#{e} #{node['environment_v2']['host'][e]['ip_lan']}:443 check"
  })
end
