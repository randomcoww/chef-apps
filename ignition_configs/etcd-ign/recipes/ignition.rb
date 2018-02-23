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
  node['environment_v2']['domain']['host'],
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

## --initial-cluster option for IP based config
initial_cluster = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "#{e}=https://#{node['environment_v2']['host'][e]['ip']['store']}:2380"
  }.join(",")


node['environment_v2']['set']['etcd']['hosts'].each do |host|
  ip = node['environment_v2']['host'][host]['ip']['store']

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
      'IP.1' => ip
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
      'IP.1' => ip
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
    # {
    #   "path" => "/opt/bin/setup-network-environment",
    #   "mode" => 493,
    #   "contents" => node['environment_v2']['url']['setup_network_environment']
    # }
  ]

  networkd = []

  if node['environment_v2']['host'][host]['ip'].is_a?(Hash)
    node['environment_v2']['host'][host]['if'].each do |i, interface|

      addr = node['environment_v2']['host'][host]['ip'][i]
      gw = node['environment_v2']['host'][host]['gw'][i]

      if !interface.nil? &&
        !addr.nil? &&
        !gw.nil?

        subnet_mask = node['environment_v2']['subnet'][i].split('/').last

        networkd << {
          "name" => "#{interface}.network",
          "contents" => {
            "Match" => {
              "Name" => interface
            },
            "Network" => {
              "LinkLocalAddressing" => "no",
              "DHCP" => "no",
              "DNS" => [
                node['environment_v2']['set']['dns']['vip'][i],
                '8.8.8.8'
              ]
            },
            "Address" => {
              "Address" => "#{addr}/#{subnet_mask}"
            },
            "Route" => {
              "Gateway" => gw,
              "Metric" => 2048
            }
          }
        }
      end
    end
  end


  etcd_environment = {
    "ETCD_NAME" => host,
    "ETCD_DATA_DIR" => "/var/lib/etcd",

    "ETCD_INITIAL_ADVERTISE_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_LISTEN_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_ADVERTISE_CLIENT_URLS" => "https://#{ip}:2379",
    "ETCD_LISTEN_CLIENT_URLS" => "https://#{ip}:2379",
    "ETCD_INITIAL_CLUSTER" => initial_cluster,
    "ETCD_INITIAL_CLUSTER_STATE" => "new",
    "ETCD_INITIAL_CLUSTER_TOKEN" => node['etcd']['cluster_name'],

    "ETCD_TRUSTED_CA_FILE" => node['etcd']['ca_path'],
    "ETCD_CERT_FILE" => node['etcd']['cert_path'],
    "ETCD_KEY_FILE" => node['etcd']['key_path'],

    "ETCD_PEER_TRUSTED_CA_FILE" => node['etcd']['ca_peer_path'],
    "ETCD_PEER_CERT_FILE" => node['etcd']['cert_peer_path'],
    "ETCD_PEER_KEY_FILE" => node['etcd']['key_peer_path'],

    "ETCD_PEER_CLIENT_CERT_AUTH" => true
  }

  systemd = [
    {
      "name" => "etcd-member.service",
      "dropins" => [
        {
          "name" => "etcd-env.conf",
          "contents" => {
            "Service" => {
              "Environment" => etcd_environment.map { |e|
                e.join('=')
              },
            }
          }
        }
      ]
    }
  ]

  # DNS basec config
  # systemd = [
  #   {
  #     "name" => "setup-network-environment.service",
  #     "contents" => {
  #       "Unit" => {
  #         "Requires" => "network-online.target",
  #         "After" => "network-online.target"
  #       },
  #       "Service" => {
  #         "Type" => "oneshot",
  #         "ExecStart" => "/opt/bin/setup-network-environment",
  #         "RemainAfterExit" => "yes"
  #       }
  #     }
  #   },
  #   {
  #     "name" => "etcd-member.service",
  #     "dropins" => [
  #       {
  #         "name" => "etcd-env.conf",
  #         "contents" => {
  #           "Unit" => {
  #             "Requires" => [
  #               # "var-lib-etcd.mount",
  #               "setup-network-environment.service",
  #             ],
  #             "After" => [
  #               # "var-lib-etcd.mount",
  #               "setup-network-environment.service"
  #             ]
  #           },
  #           "Service" => {
  #             "EnvironmentFile" => "/etc/network-environment",
  #             "ExecStart" => [
  #               '',
  #               [
  #                 "/usr/lib/coreos/etcd-wrapper",
  #                 "--data-dir",
  #                 "/var/lib/etcd",
  #                 "--discovery-srv",
  #                 domain,
  #                 "--initial-advertise-peer-urls",
  #                 "https://${DEFAULT_IPV4}:2380",
  #                 "--listen-peer-urls",
  #                 "https://${DEFAULT_IPV4}:2380",
  #                 "--listen-client-urls",
  #                 "https://${DEFAULT_IPV4}:2379",
  #                 "--advertise-client-urls",
  #                 "https://${DEFAULT_IPV4}:2379",
  #                 "--initial-cluster-state",
  #                 "new",
  #                 "--initial-cluster-token",
  #                 node['etcd']['cluster_name'],
  #
  #                 "--trusted-ca-file",
  #                 node['etcd']['ca_path'],
  #                 "--cert-file",
  #                 node['etcd']['cert_path'],
  #                 "--key-file",
  #                 node['etcd']['key_path'],
  #
  #                 "--peer-trusted-ca-file",
  #                 node['etcd']['ca_peer_path'],
  #                 "--peer-cert-file",
  #                 node['etcd']['cert_peer_path'],
  #                 "--peer-key-file",
  #                 node['etcd']['key_peer_path'],
  #
  #                 "--peer-client-cert-auth"
  #               ].join(' ')
  #             ]
  #           }
  #         }
  #       }
  #     ]
  #   }
  # ]

  node.default['ignition']['configs'][host] = {
    'base' => base,
    'files' => files,
    'directories' => directories,
    'networkd' => networkd,
    'systemd' => systemd
  }

end
