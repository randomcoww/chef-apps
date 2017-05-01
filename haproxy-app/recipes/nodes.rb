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


chef_gem 'mysql2' do
  action :install
  compile_time true
end

kea_password = Dbag::Keystore.new(
  'deploy_config', 'mysql-cluster'
).get('kea_password')

mysql_client = MysqlConfig::Client.new(120,
  username: 'Keauser',
  database: 'Kea',
  host: node['environment_v2']['mysql_lan_vip'],
  password: kea_password
)

r = mysql_client.query('SELECT hostname,address FROM lease4 WHERE client_id IS NOT NULL AND hostname!="" AND state=0')

r.each do |e|
  case e['hostname']

  when 'unifi'
    ip = IPAddr.new(e['address'], Socket::AF_INET).to_s
    if !ip.nil?

      haproxy_frontend 'unifi' do
        bind '*:8080'
        default_backend 'unifi'
      end

      haproxy_frontend 'unifi_https' do
        bind '*:8443'
        extra_options ({
          'mode' => 'tcp'
        })
        default_backend 'unifi_https'
      end

      haproxy_backend 'unifi' do
        server [ "unifi #{ip}:8080" ]
      end

      haproxy_backend 'unifi_https' do
        extra_options ({
          'mode' => 'tcp'
        })
        server [ "unifi #{ip}:8443" ]
      end
    end

  when 'transmission'
    ip = IPAddr.new(e['address'], Socket::AF_INET).to_s
    if !ip.nil?

      haproxy_frontend 'transmission' do
        bind '*:9091'
        default_backend 'transmission'
      end

      haproxy_backend 'transmission' do
        server [ "unifi #{ip}:9091" ]
      end
    end
  end
end
