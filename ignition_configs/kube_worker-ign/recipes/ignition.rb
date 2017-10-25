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


cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'kubernetes_ssl', [['CN', 'kube-ca']]
)
ca = cert_generator.root_ca


kube_config = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kubernetes']['cluster_name'],
      "cluster" => {
        "certificate-authority" => node['kubernetes']['ca_path'],
        "server" => "https://#{node['environment_v2']['set']['haproxy']['vip_lan']}:#{node['environment_v2']['haproxy']['kube-master']['port']}"
      }
    }
  ],
  "users" => [
    {
      "name" => "kube",
      "user" => {
        "client-certificate" => node['kubernetes']['cert_path'],
        "client-key" => node['kubernetes']['key_path'],
      }
    }
  ],
  "contexts" => [
    {
      "name" => "kube-context",
      "context" => {
        "cluster" => node['kubernetes']['cluster_name'],
        "user" => "kube"
      }
    }
  ],
  "current-context" => "kube-context"
}


flannel_cni = JSON.pretty_generate(node['kubernetes']['flanneld_cni'].to_hash)
flannel_cfg = JSON.pretty_generate(node['kubernetes']['flanneld_cfg'].to_hash)


node['environment_v2']['set']['kube-worker']['hosts'].each do |host|

  if_lan = node['environment_v2']['host'][host]['if_lan']

  ##
  ## kube ssl
  ##
  key = cert_generator.generate_key
  cert = cert_generator.node_cert(
    [
      ['CN', "kube-#{host}"]
    ],
    key,
    {
      "basicConstraints" => "CA:FALSE",
      "keyUsage" => 'nonRepudiation, digitalSignature, keyEncipherment',
    },
    {
      'DNS.1' => [
        '*',
        node['environment_v2']['domain']['host_lan'],
        node['environment_v2']['domain']['top']
      ].join('.')
    }
  )

  files = [
    {
      "path" => "/etc/hostname",
      "mode" => 420,
      "contents" => "data:,#{host}"
    },
    ## flannel
    # {
    #   "path" => node['kubernetes']['flanneld_cni_path'],
    #   "mode" => 420,
    #   "contents" => "data:;base64,#{Base64.encode64(flannel_cni)}"
    # },
    {
      "path" => node['kubernetes']['flanneld_cfg_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(flannel_cfg)}"
    },
    {
      "path" => ::File.join(node['kubernetes']['cni_conf_dir'], '10-flannel.conf'),
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(flannel_cni)}"
    },
    ## kube cert
    {
      "path" => node['kubernetes']['key_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(key.to_pem)}"
    },
    {
      "path" => node['kubernetes']['cert_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(cert.to_pem)}"
    },
    {
      "path" => node['kubernetes']['ca_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(ca.to_pem)}"
    },
    ## kubeconfig
    {
      "path" => node['kubernetes']['client']['kubeconfig_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(kube_config.to_hash.to_yaml)}"
    },
    # {
    #   "path" => "/opt/bin/setup-network-environment",
    #   "mode" => 493,
    #   "contents" => node['environment_v2']['url']['setup_network_environment']
    # }
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

  # flanneld_environment = {
  #   "FLANNELD_ETCD_ENDPOINTS" => "http://#{node['environment_v2']['set']['haproxy']['vip_lan']}:#{node['environment_v2']['haproxy']['etcd-client-ssl']['port']}",
  #   "FLANNELD_ETCD_PREFIX" => '/docker_overlay/network',
  #   "FLANNELD_SUBNET_DIR" => '/run/flannel/networks',
  #   "FLANNELD_SUBNET_FILE" => '/run/flannel/subnet.env',
  #   "FLANNELD_IP_MASQ" => true
  # }

  systemd = [
    {
      "name" => "kubelet.service",
      "contents" => {
        # "Unit" => {
        #   "Requires" => "setup-network-environment.service",
        #   "After" => "setup-network-environment.service"
        # },
        "Service" => {
          # "EnvironmentFile" => "/etc/network-environment",
          "Environment" => [
            "KUBELET_IMAGE_TAG=v#{node['kubernetes']['version']}_coreos.0",
            %Q{RKT_RUN_ARGS="#{[
              "--uuid-file-save=/var/run/kubelet-pod.uuid",
              "--volume var-log,kind=host,source=/var/log",
              "--mount volume=var-log,target=/var/log",
              "--volume dns,kind=host,source=/etc/resolv.conf",
              "--mount volume=dns,target=/etc/resolv.conf",
              # "--volume ssl,kind=host,source=#{node['kubernetes']['srv_path']}",
              # "--mount volume=ssl,target=#{node['kubernetes']['srv_path']}"
            ].join(' ')}"}
          ],
          "ExecStartPre" => [
            "/usr/bin/mkdir -p /etc/kubernetes/manifests",
            "/usr/bin/mkdir -p /var/log/containers",
            "-/usr/bin/rkt rm --uuid-file=/var/run/kubelet-pod.uuid"
          ],
          "ExecStart" => [
            "/usr/lib/coreos/kubelet-wrapper",
            "--register-schedulable=true",
            "--register-node=true",
            "--cni-conf-dir=#{node['kubernetes']['cni_conf_dir']}",
            "--network-plugin=cni",
            "--container-runtime=docker",
            "--allow-privileged=true",
            "--manifest-url=#{node['environment_v2']['url']['manifests']}/#{host}",
            # "--hostname-override=${DEFAULT_IPV4}",
            "--hostname-override=#{[host, domain].join('.')}",
            "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
            "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
            "--kubeconfig=#{node['kubernetes']['client']['kubeconfig_path']}",
            "--tls-cert-file=#{node['kubernetes']['cert_path']}",
            "--tls-private-key-file=#{node['kubernetes']['key_path']}"
          ].join(' '),
          "ExecStop" => "-/usr/bin/rkt stop --uuid-file=/var/run/kubelet-pod.uuid",
          "Restart" => "always",
          "RestartSec" => 10
        },
        "Install" => {
          "WantedBy" => "multi-user.target"
        }
      }
    },
    # {
    #   "name" => "flanneld.service",
    #   "dropins" => [
    #     {
    #       "name" => "etcd-env.conf",
    #       "contents" => {
    #         "Service" => {
    #           "Environment" => flanneld_environment.map { |k, v|
    #             "#{k}=#{v}"
    #           },
    #           "ExecStartPre" => "/usr/bin/etcdctl --endpoints=#{flanneld_environment['FLANNELD_ETCD_ENDPOINTS']} set #{flanneld_environment['FLANNELD_ETCD_PREFIX']}/config '#{node['kubernetes']['flanneld_cfg'].to_json}'",
    #         }
    #       }
    #     }
    #   ]
    # },
    # {
    #   "name" => "docker.service",
    #   "dropins" => [
    #     {
    #       "name" => "flannel.conf",
    #       "contents" => {
    #         "Unit" => {
    #           "Requires" => "flanneld.service",
    #           "After" => "flanneld.service"
    #         },
    #         "Service" => {
    #           "LimitNOFILE" => "infinity",
    #           "Environment" => [
    #             %Q{DOCKER_OPT_BIP=""},
    #             %Q{DOCKER_OPT_IPMASQ=""}
    #           ]
    #         }
    #       }
    #     }
    #   ]
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
  ]

  node.default['ignition']['configs'][host] = {
    'base' => base,
    'files' => files,
    'networkd' => networkd,
    'systemd' => systemd
  }

end
