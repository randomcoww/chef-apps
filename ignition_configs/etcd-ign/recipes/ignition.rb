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

domain = [
  node['environment_v2']['domain']['host_lan'],
  node['environment_v2']['domain']['top']
].join('.')


node['ignition']['etcd']['hosts'].each do |host|

  ip_lan = node['environment_v2']['host'][host]['ip_lan']
  if_lan = node['environment_v2']['host'][host]['if_lan']
  host_record = [host, domain].join('.')

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
                  "--discovery-srv=#{domain}",
                  "--initial-advertise-peer-urls=http://#{host_record}:2380",
                  "--listen-peer-urls=http://#{host_record}:2380",
                  "--listen-client-urls=http://#{host_record}:2379,http://127.0.0.1:2379",
                  "--advertise-client-urls=http://#{host_record}:2379",
                  "--initial-cluster-state=new",
                  "--initial-cluster-token=etcd-1"
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
