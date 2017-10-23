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


etcd_cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'etcd_ssl', [['CN', 'etcd-ca']]
)
etcd_ca = etcd_cert_generator.root_ca


kube_config = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "local-server" => {
        "server" => "http://127.0.0.1:8080"
      }
    }
  ]
}


flannel_cni = JSON.pretty_generate(node['kubernetes']['flanneld_cni'].to_hash)
flannel_cfg = JSON.pretty_generate(node['kubernetes']['flanneld_cfg'].to_hash)


node['environment_v2']['set']['kube-master']['hosts'].each do |host|

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
      'DNS.1' => [
        '*',
        node['environment_v2']['domain']['host_lan'],
        node['environment_v2']['domain']['top']
      ].join('.')
    }
  )

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
      'DNS.1' => 'kubernetes',
      'DNS.2' => 'kubernetes.default',
      'DNS.3' => 'kubernetes.default.svc',
      'DNS.4' => "kubernetes.default.svc.#{node['kubernetes']['cluster_domain']}",
      'DNS.5' => [
        '*',
        node['environment_v2']['domain']['host_lan'],
        node['environment_v2']['domain']['top']
      ].join('.'),
      'IP.1' => node['kubernetes']['cluster_service_ip'],
      'IP.3' => node['environment_v2']['set']['haproxy']['vip_lan']
    }
  )

  files = [
    {
      "path" => "/etc/hostname",
      "mode" => 420,
      "contents" => "data:,#{host}"
    },
    ## flannel
    {
      "path" => node['kubernetes']['flanneld_cni_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(flannel_cni)}"
    },
    {
      "path" => node['kubernetes']['flanneld_cfg_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(flannel_cfg)}"
    },
    ## kube ssl
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
    {
      "path" => node['kubernetes']['client']['kubeconfig_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(kube_config.to_hash.to_yaml)}"
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
  #   "ETCDCTL_API" => 3,
  #   "FLANNELD_ETCD_ENDPOINTS" => "https://#{node['environment_v2']['set']['haproxy']['vip_lan']}:#{node['environment_v2']['haproxy']['etcd-client-ssl']['port']}",
  #   "FLANNELD_ETCD_PREFIX" => '/docker_overlay/network',
  #   "FLANNELD_ETCD_CAFILE" => node['etcd']['ca_path'],
  #   "FLANNELD_ETCD_CERTFILE" => node['etcd']['cert_path'],
  #   "FLANNELD_ETCD_KEYFILE" => node['etcd']['key_path'],
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
              "--mount volume=dns,target=/etc/resolv.conf"
            ].join(' ')}"}
          ],
          "ExecStartPre" => [
            "/usr/bin/mkdir -p /etc/kubernetes/manifests",
            "/usr/bin/mkdir -p /var/log/containers",
            "-/usr/bin/rkt rm --uuid-file=/var/run/kubelet-pod.uuid"
          ],
          "ExecStart" => [
            "/usr/lib/coreos/kubelet-wrapper",
            "--register-schedulable=false",
            "--register-node=true",
            "--cni-conf-dir=/etc/kubernetes/cni/net.d",
            # "--network-plugin=${NETWORK_PLUGIN}",
            "--container-runtime=docker",
            "--allow-privileged=true",
            "--manifest-url=#{node['environment_v2']['url']['manifests']}/#{host}",
            # "--hostname-override=${DEFAULT_IPV4}",
            "--hostname-override=#{[host, domain].join('.')}",
            "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
            "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
            "--kubeconfig=#{node['kubernetes']['kubelet']['kubeconfig_path']}",
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
    #           "Environment" => flanneld_environment.map { |e|
    #             e.join('=')
    #           },
    #           "ExecStartPre" => [
    #             "/usr/bin/etcdctl",
    #             "--insecure-skip-tls-verify",
    #             "--cert=#{flanneld_environment['FLANNELD_ETCD_CERTFILE']}",
    #             "--key=#{flanneld_environment['FLANNELD_ETCD_KEYFILE']}",
    #             "--endpoints=#{flanneld_environment['FLANNELD_ETCD_ENDPOINTS']}",
    #             "put #{flanneld_environment['FLANNELD_ETCD_PREFIX']}/config '#{node['kubernetes']['flanneld_network'].to_json}'",
    #           ].join(' ')
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
