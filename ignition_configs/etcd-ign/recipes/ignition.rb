base = {
  "passwd" => {
    "users" => [
      {
        "name" => "core",
        # "passwordHash" => "$6$c6en5k51$fJnDYVaIDbasJQNWo.ezDdX4zfW9jsVlZAQwztQbMvRVUei/iGfGzBlhxqCAWCI6kAkrQLwy2Yr6D9HImPWWU/",
        "sshAuthorizedKeys" => node['environment_v2']['ssh_authorized_keys']['default']
      }
    ]
  }
}


node['ignition']['etcd']['hosts'].each do |host|

  ip_lan = node['environment_v2']['host'][host]['ip_lan']
  if_lan = node['environment_v2']['host'][host]['if_lan']

  files = [
    {
      "path" => "/etc/hostname",
      "mode" => 420,
      "contents" => "data:,#{host}"
    },
    {
      "path" => "/opt/bin/setup-network-environment",
      "mode" => 493,
      "contents" => node['environment_v2']['url']['setup_network_environment']
    }
  ]

  networkd = [
    {
      "name" => if_lan,
      "contents" => {
        "Match" => {
          "Name" => if_lan
        },
        "Network" => {
          "LinkLocalAddressing" => "no",
          "DHCP" => "yes",
        },
        "Address" => {
          "Address" => "#{ip_lan}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
        },
        "DHCP" => {
          "UseDNS" => "true",
          "RouteMetric" => 500
        }
      }
    }
  ]

  etcd_initial_cluster = node['environment_v2']['set']['etcd']['hosts'].map { |h|
    "#{h}=http://#{node['environment_v2']['host'][h]['ip_lan']}:2380"
  }

  systemd = [
    {
      "name" => "etcd-member",
      "dropins" => [
        {
          "name" => "etcd-env",
          "contents" => {
            "Unit" => {
              "Requires" => "setup-network-environment.service",
              "After" => "setup-network-environment.service"
            },
            "Service" => {
              "Environment" => [
                %Q{ETCD_OPTS="#{[
                  "--name=#{host}",
                  "--initial-advertise-peer-urls=http://${DEFAULT_IPV4}:2380",
                  "--listen-peer-urls=http://${DEFAULT_IPV4}:2380",
                  "--listen-client-urls=http://${DEFAULT_IPV4}:2379,http://127.0.0.1:2379",
                  "--advertise-client-urls=http://${DEFAULT_IPV4}:2379",
                  "--discovery=#{node['environment_v2']['url']['etcd_discovery']}",
                  # "--initial-cluster=#{etcd_initial_cluster.join(',')}",
                  # "--initial-cluster-state=existing",
                  # "--initial-cluster-token=etcd-1"
                ].join(' ')}"}
              ]
            }
          }
        }
      ]
    },
    {
      "name" => "setup-network-environment",
      "contents" => {
        "Unit" => {
          "Requires" => "network-online.target",
          "After" => "network-online.target"
        },
        "Service" => {
          "Type" => "oneshot",
          "ExecStart" => "/opt/bin/setup-network-environment",
          "RemainAfterExit" => "yes"
        }
      }
    }
  ]

  node.default['ignition']['configs'][host] = {
    'base' => base,
    'files' => files,
    'networkd' => networkd,
    'systemd' => systemd
  }

end
