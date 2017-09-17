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
          "DHCP" => "no",
          "DNS" => (node['environment_v2']['set']['dns']['hosts'].map { |h|
            node['environment_v2']['host'][h]['ip_lan']
          } + [ '8.8.8.8' ])
        },
        "Address" => {
          "Address" => "#{ip_lan}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
        },
        "Route" => {
          "Gateway" => node['environment_v2']['set']['gateway']['vip_lan'],
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
            "Service" => {
              "Environment" => [
                %Q{ETCD_OPTS="#{[
                  "--name=#{host}",
                  "--listen-peer-urls=http://#{ip_lan}:2380",
                  "--listen-client-urls=#{[ip_lan, '127.0.0.1'].map { |e|
                      "http://#{e}:2379"
                    }.join(',')}",
                  "--initial-advertise-peer-urls=http://#{ip_lan}:2380",
                  "--initial-cluster=#{etcd_initial_cluster.join(',')}",
                  "--initial-cluster-state=new",
                  "--initial-cluster-token=etcd-1",
                  "--advertise-client-urls=http://#{ip_lan}:2379"
                ].join(' ')}"}
              ]
            }
          }
        }
      ]
    }
  ]

  node.default['ignition']['configs'][host] = {
    'base' => base,
    'files' => files,
    'networkd' => networkd,
    'systemd' => systemd
  }

end
