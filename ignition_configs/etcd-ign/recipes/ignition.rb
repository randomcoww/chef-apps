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

  files = [
    {
      "path" => "/etc/hostname",
      "mode" => 420,
      "contents" => "data:,#{host}"
    },
    {
      "path" => "/var/lib/etcd/#{host}/member/snap/db",
      "mode" => 493,
      "contents" => "https://github.com/randomcoww/etcd-recovery/raw/master/#{host}/member/snap/db"
    }
  ]

  networkd = [
    {
      "name" => "#{if_lan}.network",
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

  etcd_environment = {
    "ETCD_DATA_DIR" => "/var/lib/etcd/#{host}",
    "ETCD_DISCOVERY_SRV" => domain,
    "ETCD_INITIAL_ADVERTISE_PEER_URLS" => "http://#{ip_lan}:2380",
    "ETCD_LISTEN_PEER_URLS" => "http://#{ip_lan}:2380",
    "ETCD_LISTEN_CLIENT_URLS" => "http://#{ip_lan}:2379,http://127.0.0.1:2379",
    "ETCD_ADVERTISE_CLIENT_URLS" => "http://#{ip_lan}:2379",
    "ETCD_INITIAL_CLUSTER_STATE" => "existing",
    "ETCD_INITIAL_CLUSTER_TOKEN" => "etcd-1"
  }

  systemd = [
    {
      "name" => "etcd-member.service",
      "dropins" => [
        {
          "name" => "etcd-env.conf",
          "contents" => {
            # "Unit" => {
            #   "Requires" => "var-lib-etcd.mount",
            #   "After" => "var-lib-etcd.mount"
            # },
            "Service" => {
              "Environment" => etcd_environment.map { |e|
                e.join('=')
              }
            }
          }
        }
      ]
    },
    # {
    #   "name" => "var-lib-etcd.mount",
    #   "contents" => {
    #     "Unit" => {
    #       "After" => "network.target"
    #     },
    #     "Mount" => {
    #       "What" => "#{node['environment_v2']['node_host']['ip_lan']}:/data/pv",
    #       "Where" => "/var/lib/etcd",
    #       "Type" => "nfs"
    #     },
    #     "Install" => {
    #       "WantedBy" => "machines.target"
    #     }
    #   }
    # }
  ]

  node.default['ignition']['configs'][host] = {
    'base' => base,
    'files' => files,
    'networkd' => networkd,
    'systemd' => systemd
  }

end
