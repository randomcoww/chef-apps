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
  'frontend transmission' => {
    'default_backend' => 'transmission',
    'bind' => "*:9091",
    'maxconn' => 2000
  },
  'backend transmission' => {
    'server' => node['environment_v2']['set']['haproxy']['hosts'].map { |e|
        "#{e} #{node['environment_v2']['host'][e]['ip_lan']}:30063 check"
      }
  },
  'frontend sshd' => {
    'default_backend' => 'sshd',
    'bind' => "*:2222",
    'maxconn' => 2000
  },
  'backend sshd' => {
    'server' => node['environment_v2']['set']['haproxy']['hosts'].map { |e|
        "#{e} #{node['environment_v2']['host'][e]['ip_lan']}:32222 check"
      }
  },
  'frontend mpd_control' => {
    'default_backend' => 'mpd_control',
    'bind' => "*:6600",
    'maxconn' => 2000
  },
  'backend mpd_control' => {
    'server' => node['environment_v2']['set']['haproxy']['hosts'].map { |e|
        "#{e} #{node['environment_v2']['host'][e]['ip_lan']}:30061 check"
      }
  },
  'frontend mpd_stream' => {
    'default_backend' => 'mpd_stream',
    'bind' => "*:8000",
    'maxconn' => 2000
  },
  'backend mpd_stream' => {
    'server' => node['environment_v2']['set']['haproxy']['hosts'].map { |e|
        "#{e} #{node['environment_v2']['host'][e]['ip_lan']}:30062 check"
      }
  }
})
