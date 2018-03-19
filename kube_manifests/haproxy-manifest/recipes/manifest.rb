haproxy_config_path = '/etc/haproxy/haproxy.cfg'
haproxy_pid_path = '/run/haproxy.pid'

config_base = {
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
}


node['environment_v2']['set'].each_value do |config|
  if !config.has_key?('lb')
    next
  end

  if !config.has_key?('hosts')
    next
  end

  services = {}

  config['lb'].each do |target_set, target_config|
    if !target_config.is_a?(Hash)
      next
    end

    backends = node['environment_v2']['set'][target_set]['hosts'].map { |host|
      [host, node['environment_v2']['host'][host]['ip']['store']]
    }

    target_config.each do |config_key, ports|

      service_name = "#{target_set}-#{config_key}"

      services["frontend #{service_name}"] = {
        'default_backend' => service_name,
        'bind' => "*:#{ports['port']}"
      }

      services["backend #{service_name}"] = {
        "server" => backends.map { |host, ip|
          "#{host} #{ip}:#{ports['hostport']} check"
        }
      }
    end
  end


  haproxy_manifest = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      "namespace" => "kube-system",
      "name" => "haproxy"
    },
    "spec" => {
      "restartPolicy" => "Always",
      "hostNetwork" => true,
      "initContainers" => [
        "name" => "haproxy-config",
        "image" => node['kube']['images']['envwriter'],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => HaproxyHelper::ConfigGenerator.generate_from_hash(config_base.merge(services))
          }
        ],
        "args" => [
          haproxy_config_path
        ],
        "volumeMounts" => [
          {
            "name" => "haproxy-config",
            "mountPath" => ::File.dirname(haproxy_config_path)
          }
        ]
      ],
      "containers" => [
        {
          "name" => "haproxy",
          "image" => node['kube']['images']['haproxy'],
          "args" => [
            "haproxy",
            "-V",
            "-f",
            haproxy_config_path,
            "-p",
            haproxy_pid_path,
          ],
          "volumeMounts" => [
            {
              "name" => "haproxy-config",
              "mountPath" => ::File.dirname(haproxy_config_path)
            }
          ]
        }
      ],
      "volumes" => [
        {
          "name" => "haproxy-config",
          "emptyDir" => {}
        }
      ]
    }
  }

  config['hosts'].each do |host|
    node.default['kubernetes']['static_pods'][host]['haproxy'] = haproxy_manifest
  end

end
