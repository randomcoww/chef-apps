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


kube_config = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kubernetes']['cluster_name'],
      "cluster" => {
        "certificate-authority" => node['kubernetes']['ca_path'],
        "server" => "https://#{node['environment_v2']['set']['haproxy']['vip']['store']}:#{node['environment_v2']['haproxy']['kube-master']['port']}"
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
    {}
  )

  directories = []

  files = [
    {
      "path" => "/etc/hostname",
      "mode" => 420,
      "contents" => "data:,#{host}"
    },
    ## flannel
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
    ## setup-network-environment
    {
      "path" => "/opt/bin/setup-network-environment",
      "mode" => 493,
      "contents" => node['environment_v2']['url']['setup_network_environment']
    }
  ]


  networkd = []

  # node['environment_v2']['host'][host]['if'].each do |i, interface|
  #   if !interface.nil?
  #
  #     networkd << {
  #       "name" => "#{interface}.network",
  #       "contents" => {
  #         "Match" => {
  #           "Name" => interface
  #         },
  #         "Network" => {
  #           "LinkLocalAddressing" => "no",
  #           "DHCP" => "yes",
  #         },
  #         "DHCP" => {
  #           "UseDNS" => "true",
  #           "RouteMetric" => 500,
  #           # "UseHostname" => "%m"
  #         }
  #       }
  #     }
  #   end
  # end


  systemd = [
    {
      "name" => "kubelet.service",
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
            # "--register-schedulable=true",
            "--register-node=true",
            "--cni-conf-dir=#{node['kubernetes']['cni_conf_dir']}",
            "--network-plugin=cni",
            "--container-runtime=docker",
            "--allow-privileged=true",
            "--manifest-url=#{node['environment_v2']['url']['manifests']}/#{host}",
            "--hostname-override=${DEFAULT_IPV4}",
            "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
            "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
            "--kubeconfig=#{node['kubernetes']['client']['kubeconfig_path']}",
            "--tls-cert-file=#{node['kubernetes']['cert_path']}",
            "--tls-private-key-file=#{node['kubernetes']['key_path']}",
            "--docker-disable-shared-pid=false",
            # "--feature-gates=CustomPodDNS=true"
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
