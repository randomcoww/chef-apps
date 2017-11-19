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

## client
etcd_cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'etcd_ssl', [['CN', 'etcd-ca']]
)
etcd_ca = etcd_cert_generator.root_ca

## peer
etcd_peer_cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'etcd_peer_ssl', [['CN', 'etcd-peer-ca']]
)
etcd_peer_ca = etcd_peer_cert_generator.root_ca


node['environment_v2']['set']['etcd']['hosts'].each do |host|

  if_lan = node['environment_v2']['host'][host]['if_lan']

  ##
  ## etcd ssl
  ##
  etcd_key = etcd_cert_generator.generate_key
  etcd_cert = etcd_cert_generator.node_cert(
    [
      ['CN', "etcd-#{host}"]
    ],
    etcd_key,
    {
      "basicConstraints" => "CA:FALSE",
      "keyUsage" => 'nonRepudiation, digitalSignature, keyEncipherment',
    },
    {
      'DNS.1' => [host, domain].join('.'),
      # 'DNS.1' => ['*', domain].join('.'),
      # 'IP.1' => node['environment_v2']['set']['haproxy']['vip_lan']
    }
  )

  ##
  ## etcd peer ssl
  ##
  etcd_peer_key = etcd_peer_cert_generator.generate_key
  etcd_peer_cert = etcd_peer_cert_generator.node_cert(
    [
      ['CN', "etcd-peer-#{host}"]
    ],
    etcd_peer_key,
    {
      "basicConstraints" => "CA:FALSE",
      "keyUsage" => 'nonRepudiation, digitalSignature, keyEncipherment',
    },
    {
      'DNS.1' => [host, domain].join('.'),
      # 'DNS.1' => ['*', domain].join('.')
    }
  )

  directories = []

  files = [
    {
      "path" => "/etc/hostname",
      "mode" => 420,
      "contents" => "data:,#{host}"
    },
    ## etcd ssl
    {
      "path" => node['etcd']['key_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(etcd_key.to_pem)}"
    },
    {
      "path" => node['etcd']['cert_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(etcd_cert.to_pem)}"
    },
    {
      "path" => node['etcd']['ca_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(etcd_ca.to_pem)}"
    },
    ## etcd peer ssl
    {
      "path" => node['etcd']['key_peer_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(etcd_peer_key.to_pem)}"
    },
    {
      "path" => node['etcd']['cert_peer_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(etcd_peer_cert.to_pem)}"
    },
    {
      "path" => node['etcd']['ca_peer_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(etcd_peer_ca.to_pem)}"
    },
    ## setup-network-environment
    {
      "path" => "/opt/bin/setup-network-environment",
      "mode" => 493,
      "contents" => node['environment_v2']['url']['setup_network_environment']
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
          "RouteMetric" => 500,
          # "UseHostname" => "%m"
        }
      }
    }
  ]

  # etcd_environment = {
  #   "ETCD_DATA_DIR" => "/var/lib/etcd/#{host}",
  #   "ETCD_DISCOVERY_SRV" => domain,
  #   "ETCD_INITIAL_ADVERTISE_PEER_URLS" => "https://#{hostname}:2380",
  #   "ETCD_LISTEN_PEER_URLS" => "https://#{hostname}:2380",
  #   "ETCD_LISTEN_CLIENT_URLS" => "https://#{hostname}:2379,https://127.0.0.1:2379",
  #   "ETCD_ADVERTISE_CLIENT_URLS" => "https://#{hostname}:2379",
  #   "ETCD_INITIAL_CLUSTER_STATE" => "existing",
  #   "ETCD_INITIAL_CLUSTER_TOKEN" => "etcd-1",
  #
  #   "ETCD_TRUSTED_CA_FILE" => node['etcd']['ca_path'],
  #   "ETCD_CERT_FILE" => node['etcd']['cert_path'],
  #   "ETCD_KEY_FILE" => node['etcd']['key_path'],
  #
  #   "ETCD_PEER_TRUSTED_CA_FILE" => node['etcd']['ca_peer_path'],
  #   "ETCD_PEER_CERT_FILE" => node['etcd']['cert_peer_path'],
  #   "ETCD_PEER_KEY_FILE" => node['etcd']['key_peer_path'],
  #   "ETCD_PEER_CLIENT_CERT_AUTH" => true
  # }

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

    {
      "name" => "setup-network-environment.service",
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
    },
    {
      "name" => "etcd-member.service",
      "dropins" => [
        {
          "name" => "etcd-env.conf",
          "contents" => {
            "Unit" => {
              "Requires" => [
                # "var-lib-etcd.mount",
                "setup-network-environment.service",
              ],
              "After" => [
                # "var-lib-etcd.mount",
                "setup-network-environment.service"
              ]
            },
            "Service" => {
              # "Environment" => etcd_environment.map { |e|
              #   e.join('=')
              # }
              "EnvironmentFile" => "/etc/network-environment",
              "ExecStart" => [
                '',
                [
                  "/usr/lib/coreos/etcd-wrapper",
                  "--data-dir",
                  "/var/lib/etcd",
                  "--discovery-srv",
                  domain,
                  "--initial-advertise-peer-urls",
                  "https://${DEFAULT_IPV4}:2380",
                  "--listen-peer-urls",
                  "https://${DEFAULT_IPV4}:2380",
                  "--listen-client-urls",
                  "https://${DEFAULT_IPV4}:2379,http://127.0.0.1:2379",
                  "--advertise-client-urls",
                  "https://${DEFAULT_IPV4}:2379",
                  "--initial-cluster-state",
                  "new",
                  "--initial-cluster-token",
                  node['etcd']['cluster_name'],

                  "--trusted-ca-file",
                  node['etcd']['ca_path'],
                  "--cert-file",
                  node['etcd']['cert_path'],
                  "--key-file",
                  node['etcd']['key_path'],

                  "--peer-trusted-ca-file",
                  node['etcd']['ca_peer_path'],
                  "--peer-cert-file",
                  node['etcd']['cert_peer_path'],
                  "--peer-key-file",
                  node['etcd']['key_peer_path'],

                  "--peer-client-cert-auth"
                ].join(' ')
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
    'directories' => directories,
    'networkd' => networkd,
    'systemd' => systemd
  }

end
