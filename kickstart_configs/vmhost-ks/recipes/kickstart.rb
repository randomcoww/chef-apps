[
  node['kickstart']['config_path']
].each do |d|
  directory d do
    recursive true
    action [:create]
  end
end


domain = [
  node['environment_v2']['domain']['host'],
  node['environment_v2']['domain']['top']
].join('.')

subnet = node['environment_v2']['subnet']

#
# SSL
#

## kube master
cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'kubernetes_ssl', [['CN', 'kube-ca']]
)
ca = cert_generator.root_ca

## etcd client
etcd_cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'etcd_ssl', [['CN', 'etcd-ca']]
)
etcd_ca = etcd_cert_generator.root_ca

## etcd peer
etcd_peer_cert_generator = OpenSSLHelper::CertGenerator.new(
  'deploy_config', 'etcd_peer_ssl', [['CN', 'etcd-peer-ca']]
)
etcd_peer_ca = etcd_peer_cert_generator.root_ca

#
# kubelet config
#
kube_config = {
  "apiVersion" => "v1",
  "kind" => "Config",
  "clusters" => [
    {
      "name" => node['kubernetes']['cluster_name'],
      "cluster" => {
        "server" => "http://127.0.0.1:#{node['kubernetes']['insecure_port']}"
      }
    }
  ],
  "users" => [
    {
      "name" => "kube",
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

cni_conf = node['kubernetes']['cni_conf']
flannel_cfg = node['kubernetes']['flanneld_conf']

#
# host config
#
node['environment_v2']['set']['vmhost']['hosts'].each do |host|

  interfaces = node['environment_v2']['host'][host]['if']
  ips = node['environment_v2']['host'][host]['ip']
  ip = ips['store']

  directories = [
    '/var/lib/kubelet',
    '/etc/kubernetes',
    ::File.dirname(node['kubernetes']['cni_conf_path']),
    ::File.dirname(node['kubernetes']['flanneld_conf_path'])
  ]


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
      'IP.1' => node['kubernetes']['cluster_service_ip'],
      'IP.2' => node['environment_v2']['set']['haproxy']['vip']['store']
    }
  )

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


  # write all files
  files = [
    # disable annoying systemd-resolv dns features
    {
      "path" => '/etc/systemd/resolved.conf',
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "Resolve" => {
          "FallbackDNS" => '',
          "DNSStubListener" => "no"
        }
      })
    },
    # kubelet using rkt and coreos wrapper method
    {
      "path" => '/etc/systemd/system/kubelet.service',
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "Service" => {
          "ExecStartPre" => [
            "/usr/bin/mkdir -p /var/log/containers",
            "-/usr/bin/rkt rm --uuid-file=/var/run/kubelet-pod.uuid"
          ],
          "ExecStart" => [
            "/usr/bin/rkt",
            "run",
            "--insecure-options=image",
            "--uuid-file-save=/var/run/kubelet-pod.uuid",
            "--volume dns,kind=host,source=/etc/resolv.conf",
            "--mount volume=dns,target=/etc/resolv.conf",

            "--volume coreos-etc-kubernetes,kind=host,source=/etc/kubernetes,readOnly=false",
            "--volume coreos-etc-ssl-certs,kind=host,source=/etc/ssl/certs,readOnly=true",
            "--volume coreos-usr-share-certs,kind=host,source=/etc/pki/ca-trust,readOnly=true",
            "--volume coreos-var-lib-docker,kind=host,source=/var/lib/docker,readOnly=false",
            "--volume coreos-var-lib-kubelet,kind=host,source=/var/lib/kubelet,readOnly=false,recursive=true",
            "--volume coreos-var-log,kind=host,source=/var/log,readOnly=false",
            "--volume coreos-os-release,kind=host,source=/usr/lib/os-release,readOnly=true",
            "--volume coreos-run,kind=host,source=/run,readOnly=false",
            "--volume coreos-lib-modules,kind=host,source=/lib/modules,readOnly=true",
            "--mount volume=coreos-etc-kubernetes,target=/etc/kubernetes",
            "--mount volume=coreos-etc-ssl-certs,target=/etc/ssl/certs",
            "--mount volume=coreos-usr-share-certs,target=/etc/pki/ca-trust",
            "--mount volume=coreos-var-lib-docker,target=/var/lib/docker",
            "--mount volume=coreos-var-lib-kubelet,target=/var/lib/kubelet",
            "--mount volume=coreos-var-log,target=/var/log",
            "--mount volume=coreos-os-release,target=/etc/os-release",
            "--mount volume=coreos-run,target=/run",
            "--mount volume=coreos-lib-modules,target=/lib/modules",
            "--hosts-entry host",

            "--stage1-from-dir=stage1-fly.aci",
            "docker://#{node['kube']['images']['hyperkube']}",
            "--exec=/kubelet",
            "--",

            "--register-node=true",
            "--cni-conf-dir=#{::File.dirname(node['kubernetes']['cni_conf_path'])}",
            "--network-plugin=cni",
            "--container-runtime=docker",
            "--allow-privileged=true",
            "--manifest-url=#{node['environment_v2']['url']['manifests']}/#{host}",
            "--hostname-override=#{ip}",
            "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
            "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
            "--kubeconfig=#{node['kubernetes']['client']['kubeconfig_path']}",
            "--docker-disable-shared-pid=false",
            "--image-gc-high-threshold=0",
            "--image-gc-low-threshold=0",
            "--fail-swap-on=false",
            "--cgroup-driver=systemd",
          ].join(' '),
          "ExecStop" => "-/usr/bin/rkt stop --uuid-file=/var/run/kubelet-pod.uuid",
          "Restart" => "always",
          "RestartSec" => 10
        },
        "Install" => {
          "WantedBy" => "multi-user.target"
        }
      })
    },
    # other systemd
    # ipmi fan control:
    #
    # ommited full speed:
    # ExecStartPre=/usr/bin/ipmitool raw 0x30 0x45 0x01 0x01
    #
    # setting a specific duty cycle:
    # fan control 0x30 0x70 0x66
    # get 0x00, set 0x01
    # zone FAN 1,2,.. 0x00, FAN A,B,.. 0x01
    # duty cycle 0x00-0x64
    {
      "path" => '/etc/systemd/system/fancontrol.service',
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "Unit" => {
          "Description" => "Fan Control",
          "After" => "ipmievd.service"
        },
        "Service" => {
          "Type" => "oneshot",
          "ExecStart" => [
            "/usr/bin/ipmitool raw 0x30 0x70 0x66 0x01 0x00 0x10",
            "/usr/bin/ipmitool raw 0x30 0x70 0x66 0x01 0x01 0x10"
          ]
        },
        "Install" => {
          "WantedBy" => "multi-user.target"
        }
      })
    },
    # systemd networks
    ## lan network
    {
      "path" => "/etc/systemd/network/#{interfaces['lan']}.network",
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "Match" => {
          "Name" => interfaces['lan']
        },
        "Network" => {
          "LinkLocalAddressing" => "no",
          "DHCP" => "no",
          "VLAN" => "wan"
        }
      })
    },
    ## store
    {
      "path" => "/etc/systemd/network/#{interfaces['store']}.network",
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "Match" => {
          "Name" => interfaces['store']
        },
        "Network" => {
          "LinkLocalAddressing" => "no",
          "DHCP" => "no",
          "MACVLAN" => "#{interfaces['store']}_host"
        }
      })
    },
    ## allow guests to access the host over macvlan
    {
      "path" => "/etc/systemd/network/#{interfaces['store']}_host.netdev",
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "NetDev" => {
          "Name" => "#{interfaces['store']}_host",
          "Kind" => "macvlan"
        },
        "MACVLAN" => {
          "Mode" => "bridge"
        }
      })
    },
    {
      "path" => "/etc/systemd/network/#{interfaces['store']}_host.network",
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "Match" => {
          "Name" => "#{interfaces['store']}_host"
        },
        "Network" => {
          "LinkLocalAddressing" => "no",
          "DHCP" => "yes",
        },
        "Address" => {
          "Address" => "#{ips['store']}/#{subnet['store'].split('/').last}"
        }
      })
    },
    ## wan
    {
      "path" => "/etc/systemd/network/#{interfaces['wan']}.netdev",
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "NetDev" => {
          "Name" => interfaces['wan'],
          "Kind" => "vlan"
        },
        "VLAN" => {
          "Id" => 30
        }
      })
    },
    {
      "path" => "/etc/systemd/network/#{interfaces['wan']}.network",
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "Match" => {
          "Name" => interfaces['wan']
        },
        "Network" => {
          "LinkLocalAddressing" => "no",
          "DHCP" => "no",
        }
      })
    },
    ## zfssync
    {
      "path" => "/etc/systemd/network/#{interfaces['zfssync']}.network",
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "Match" => {
          "Name" => interfaces['zfssync']
        },
        "Network" => {
          "LinkLocalAddressing" => "no",
          "DHCP" => "no",
        },
        "Address" => {
          "Address" => "#{ips['zfssync']}/#{subnet['zfssync'].split('/').last}"
        }
      })
    },
    # enable serial console
    {
      "append" => true,
      "path" => '/etc/default/grub',
      "data" => <<-EOF
GRUB_TERMINAL="console serial"
GRUB_SERIAL_COMMAND="serial --unit=1 --speed=115200 --word=8 --parity=no --stop=1"
EOF
    },
    # load NIC VFs
    {
      "path" => '/etc/modprobe.d/local.conf',
      "data" => [
        # vfio-pci ids=1002:ffffffff:ffffffff:ffffffff:00030000:ffff00ff,1002:ffffffff:ffffffff:ffffffff:00040300:ffffffff,10de:ffffffff:ffffffff:ffffffff:00030000:ffff00ff,10de:ffffffff:ffffffff:ffffffff:00040300:ffffffff
        "kvm ignore_msrs=1",
        "kvm-intel nested=1",
        "igb max_vfs=16",
        "ixgbe max_vfs=16",
      ].map { |e| "options #{e}" }.join($/)
    },
    # {
    #   "path" => '/etc/dnf/dnf.conf',
    #   "data" => [
    #     "exclude=kernel*"
    #   ].join($/)
    # },
    # DNF automatic
    {
      "path" => '/etc/dnf/automatic.conf',
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "commands" => {
          "apply_updates" => true,
          "upgrade_type" => "default"
        },
        "emitters" => {
          "emit_via" => "motd"
        }
      }),
    },
    # SSH
    {
      "path" => '/etc/ssh/sshd_config',
      "data" => <<-EOF
Subsystem sftp internal-sftp
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
EOF
    },
    # kubelet
    {
      "path" => node['kubernetes']['client']['kubeconfig_path'],
      "data" => kube_config.to_hash.to_yaml
    },
    {
      "path" => node['kubernetes']['flanneld_conf_path'],
      "data" => JSON.pretty_generate(flannel_cfg.to_hash)
    },
    {
      "path" => node['kubernetes']['cni_conf_path'],
      "data" => JSON.pretty_generate(cni_conf.to_hash)
    },
    ## ssl
    {
      "path" => node['kubernetes']['key_path'],
      "data" => key.to_pem
    },
    {
      "path" => node['kubernetes']['cert_path'],
      "data" => cert.to_pem
    },
    {
      "path" => node['kubernetes']['ca_path'],
      "data" => ca.to_pem
    },
    ## etcd ssl
    {
      "path" => node['etcd']['key_path'],
      "data" => etcd_key.to_pem
    },
    {
      "path" => node['etcd']['cert_path'],
      "data" => etcd_cert.to_pem
    },
    {
      "path" => node['etcd']['ca_path'],
      "data" => etcd_ca.to_pem
    },
    ## etcd peer ssl
    {
      "path" => node['etcd']['key_peer_path'],
      "data" => etcd_peer_key.to_pem
    },
    {
      "path" => node['etcd']['cert_peer_path'],
      "data" => etcd_peer_cert.to_pem
    },
    {
      "path" => node['etcd']['ca_peer_path'],
      "data" => etcd_peer_ca.to_pem
    },
  ]


  template ::File.join(node['kickstart']['config_path'], "#{host}.ks") do
    source 'kickstart.erb'
    variables ({
      hostname: host,
      username: node['kickstart']['vmhost']['username'],
      password: node['kickstart']['vmhost']['password'],
      groups: node['kickstart']['vmhost']['groups'],
      sshkeys: node['kickstart']['vmhost']['sshkeys'],
      boot_params: node['kickstart']['vmhost']['boot_params'],
      packages_install: node['kickstart']['vmhost']['packages_install'],
      packages_remove: node['kickstart']['vmhost']['packages_remove'],
      directories: directories,
      files: files,
      services_enable: node['kickstart']['vmhost']['services_enable'],
    })
  end

end
