node.default['kubelet']['haproxy']['config'] = HaproxyHelper::ConfigGenerator.generate_from_hash({
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
  },
  # 'frontend mysql' => {
  #   'default_backend' => 'mysql',
  #   'bind' => "*:3306",
  #   'maxconn' => 2000
  # },
  # 'backend mysql' => {
  #   'server' => node['environment_v2']['set']['kea-mysql']['hosts'].map { |e|
  #       "#{e} #{node['environment_v2']['host'][e]['ip_lan']}:3306 check"
  #     }
  # }
})
