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


cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'kubernetes_ssl', [['CN', 'kube-ca']]
)
ca = cert_generator.root_ca


kubelet_kube_config = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kubernetes']['cluster_name'],
      "cluster" => {
        "certificate-authority" => node['kubernetes']['ca_path'],
        # "server" => "https://#{node['kubernetes']['master_ip']}"
      }
    }
  ],
  "users" => [
    {
      "name" => "kubelet",
      "user" => {
        "client-certificate" => node['kubernetes']['cert_path'],
        "client-key" => node['kubernetes']['key_path'],
        # "token" => node['kubernetes']['tokens']['kubelet']
      }
    }
  ],
  "contexts" => [
    {
      "name" => "kubelet-context",
      "context" => {
        "cluster" => node['kubernetes']['cluster_name'],
        "user" => "kubelet"
      }
    }
  ],
  "current-context" => "kubelet-context"
}


kube_proxy_kube_config = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kubernetes']['cluster_name'],
      "cluster" => {
        "certificate-authority" => node['kubernetes']['ca_path'],
        # "server" => "https://#{node['kubernetes']['master_ip']}"
      }
    }
  ],
  "users" => [
    {
      "name" => "kube_proxy",
      "user" => {
        "client-certificate" => node['kubernetes']['cert_path'],
        "client-key" => node['kubernetes']['key_path'],
        # "token" => node['kubernetes']['tokens']['kube_proxy']
      }
    }
  ],
  "contexts" => [
    {
      "name" => "kube-proxy-context",
      "context" => {
        "cluster" => node['kubernetes']['cluster_name'],
        "user" => "kube_proxy"
      }
    }
  ],
  "current-context" => "kube-proxy-context"
}


node['ignition']['kube_worker']['hosts'].each do |host|

  if_lan = node['environment_v2']['host'][host]['if_lan']

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
      "path" => node['kubernetes']['kubelet']['kubeconfig_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(kubelet_kube_config.to_hash.to_yaml)}"
    },
    {
      "path" => node['kubernetes']['kube_proxy']['kubeconfig_path'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(kube_proxy_kube_config.to_hash.to_yaml)}"
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
        "DHCP" => {
          "UseDNS" => "true",
          "RouteMetric" => 500
        }
      }
    }
  ]

  flanneld_environment = {
    "FLANNELD_ETCD_ENDPOINTS" => "http://#{node['environment_v2']['set']['haproxy']['vip_lan']}:#{node['environment_v2']['service']['etcd']['bind']}",
    "FLANNELD_ETCD_PREFIX" => '/docker_overlay/network',
    "FLANNELD_SUBNET_DIR" => '/run/flannel/networks',
    "FLANNELD_SUBNET_FILE" => '/run/flannel/subnet.env',
    "FLANNELD_IP_MASQ" => true
  }

  systemd = [
    {
      "name" => "kubelet",
      "contents" => {
        "Unit" => {
          "Requires" => "setup-network-environment.service",
          "After" => "setup-network-environment.service"
        },
        "Service" => {
          "EnvironmentFile" => "/etc/network-environment",
          "Environment" => [
            "KUBELET_IMAGE_TAG=v#{node['kubernetes']['version']}_coreos.0",
            %Q{RKT_RUN_ARGS="#{[
              "--uuid-file-save=/var/run/kubelet-pod.uuid",
              "--volume var-log,kind=host,source=/var/log",
              "--mount volume=var-log,target=/var/log",
              "--volume dns,kind=host,source=/etc/resolv.conf",
              "--mount volume=dns,target=/etc/resolv.conf",
              "--volume ssl,kind=host,source=#{node['kubernetes']['srv_path']}",
              "--mount volume=ssl,target=#{node['kubernetes']['srv_path']}"
            ].join(' ')}"}
          ],
          "ExecStartPre" => [
            "/usr/bin/mkdir -p /etc/kubernetes/manifests",
            "/usr/bin/mkdir -p /var/log/containers",
            "-/usr/bin/rkt rm --uuid-file=/var/run/kubelet-pod.uuid"
          ],
          "ExecStart" => [
            "/usr/lib/coreos/kubelet-wrapper",
            "--api-servers=https://#{node['environment_v2']['set']['haproxy']['vip_lan']}:#{node['environment_v2']['service']['kube_master']['bind']}",
            "--register-schedulable=true",
            "--register-node=true",
            "--cni-conf-dir=/etc/kubernetes/cni/net.d",
            # "--network-plugin=${NETWORK_PLUGIN}",
            "--container-runtime=docker",
            "--allow-privileged=true",
            "--manifest-url=#{node['environment_v2']['url']['manifests']}/#{host}",
            "--hostname-override=${DEFAULT_IPV4}",
            "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
            "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
            "--kubeconfig=#{node['kubernetes']['kubelet']['kubeconfig_path']}",
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
    {
      "name" => "flanneld",
      "dropins" => [
        {
          "name" => "etcd-env",
          "contents" => {
            "Service" => {
              "Environment" => flanneld_environment.map { |k, v|
                "#{k}=#{v}"
              },
              "ExecStartPre" => "/usr/bin/etcdctl --endpoints=#{flanneld_environment['FLANNELD_ETCD_ENDPOINTS']} set #{flanneld_environment['FLANNELD_ETCD_PREFIX']}/config '#{node['kubernetes']['flanneld_network'].to_json}'",
            }
          }
        }
      ]
    },
    {
      "name" => "docker",
      "dropins" => [
        {
          "name" => "flannel",
          "contents" => {
            "Unit" => {
              "Requires" => "flanneld.service",
              "After" => "flanneld.service"
            },
            "Service" => {
              "LimitNOFILE" => "infinity",
              "Environment" => [
                %Q{DOCKER_OPT_BIP=""},
                %Q{DOCKER_OPT_IPMASQ=""}
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
