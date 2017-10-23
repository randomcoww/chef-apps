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


node['environment_v2']['set']['etcd']['hosts'].each do |host|

  if_lan = node['environment_v2']['host'][host]['if_lan']
  hostname = [host, domain].join('.')

  files = [
    {
      "path" => "/etc/hostname",
      "mode" => 420,
      "contents" => "data:,#{host}"
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
    "ETCD_INITIAL_ADVERTISE_PEER_URLS" => "http://#{hostname}:2380",
    "ETCD_LISTEN_PEER_URLS" => "http://#{hostname}:2380",
    "ETCD_LISTEN_CLIENT_URLS" => "http://#{hostname}:2379,http://127.0.0.1:2379",
    "ETCD_ADVERTISE_CLIENT_URLS" => "http://#{hostname}:2379",
    "ETCD_INITIAL_CLUSTER_STATE" => "existing",
    "ETCD_INITIAL_CLUSTER_TOKEN" => "etcd-1"
  }

  systemd = [
    # {
    #   "name" => "kubelet.service",
    #   "contents" => {
    #     # "Unit" => {
    #     #   "Requires" => "setup-network-environment.service",
    #     #   "After" => "setup-network-environment.service"
    #     # },
    #     "Service" => {
    #       # "EnvironmentFile" => "/etc/network-environment",
    #       "Environment" => [
    #         "KUBELET_IMAGE_TAG=v#{node['kubernetes']['version']}_coreos.0",
    #         %Q{RKT_RUN_ARGS="#{[
    #           "--uuid-file-save=/var/run/kubelet-pod.uuid",
    #           "--volume var-log,kind=host,source=/var/log",
    #           "--mount volume=var-log,target=/var/log",
    #           "--volume dns,kind=host,source=/etc/resolv.conf",
    #           "--mount volume=dns,target=/etc/resolv.conf",
    #         ].join(' ')}"}
    #       ],
    #       "ExecStartPre" => [
    #         "/usr/bin/mkdir -p /etc/kubernetes/manifests",
    #         "/usr/bin/mkdir -p /var/log/containers",
    #         "-/usr/bin/rkt rm --uuid-file=/var/run/kubelet-pod.uuid"
    #       ],
    #       "ExecStart" => [
    #         "/usr/lib/coreos/kubelet-wrapper",
    #         "--register-schedulable=false",
    #         "--register-node=true",
    #         "--cni-conf-dir=/etc/kubernetes/cni/net.d",
    #         # "--network-plugin=${NETWORK_PLUGIN}",
    #         "--container-runtime=docker",
    #         "--allow-privileged=true",
    #         "--manifest-url=#{node['environment_v2']['url']['manifests']}/#{host}",
    #         # "--hostname-override=#{ip_lan}",
    #         # "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
    #         # "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
    #         "--make-iptables-util-chains=false",
    #       ].join(' '),
    #       "ExecStop" => "-/usr/bin/rkt stop --uuid-file=/var/run/kubelet-pod.uuid",
    #       "Restart" => "always",
    #       "RestartSec" => 10
    #     },
    #     "Install" => {
    #       "WantedBy" => "multi-user.target"
    #     }
    #   }
    # },
    # {
    #   "name" => "setup-network-environment.service",
    #   "contents" => {
    #     "Unit" => {
    #       "Requires" => "network-online.target",
    #       "After" => "network-online.target"
    #     },
    #     "Service" => {
    #       "Type" => "oneshot",
    #       "ExecStart" => "/opt/bin/setup-network-environment",
    #       "RemainAfterExit" => "yes"
    #     }
    #   }
    # }

    {
      "name" => "etcd-member.service",
      "dropins" => [
        {
          "name" => "etcd-env.conf",
          "contents" => {
            "Unit" => {
              "Requires" => "var-lib-etcd.mount",
              "After" => "var-lib-etcd.mount"
            },
            "Service" => {
              "Environment" => etcd_environment.map { |e|
                e.join('=')
              }
            }
          }
        }
      ]
    },
    {
      "name" => "var-lib-etcd.mount",
      "contents" => {
        "Unit" => {
          "After" => "network.target"
        },
        "Mount" => {
          "What" => "#{node['environment_v2']['node_host']['ip_lan']}:/data/pv",
          "Where" => "/var/lib/etcd",
          "Type" => "nfs"
        },
        "Install" => {
          "WantedBy" => "machines.target"
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
