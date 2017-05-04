require 'ipaddr'


haproxy_install 'package' do
  action :create
end

haproxy_config_global 'lb' do
  log "127.0.0.1 local0"
  maxconn 256
end

haproxy_config_defaults 'lb' do
  log 'global'
  mode 'http'
  retries 3
  option ([
    'httplog',
    'dontlognull',
    'redispatch'
  ])
  timeout ({
    connect: '5000ms',
    client: '10000ms',
    server: '10000ms'
  })
end
