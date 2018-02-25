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

# no cluster because i only have two physical nodes...
## --initial-cluster option for IP based config
# initial_cluster = node['environment_v2']['set']['etcd']['hosts'].map { |e|
#     "#{e}=https://#{node['environment_v2']['host'][e]['ip']['store']}:2380"
#   }.join(",")


subnet = node['environment_v2']['subnet']

node['environment_v2']['set']['vmhost']['hosts'].each do |host|

  interfaces = node['environment_v2']['host'][host]['if']
  ips = node['environment_v2']['host'][host]['ip']

  ip = ips['store']

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


  etcd_initial_cluster = "https://#{ip}:2379"

  # write all files
  files = [
    {
      # disable annoying systemd-resolv dns features
      "path" => '/etc/systemd/resolved.conf',
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "Resolve" => {
          "FallbackDNS" => '',
          "DNSStubListener" => "no"
        }
      })
    },
    {
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
      "path" => '/etc/systemd/system/fancontrol.service',
      "data" => SystemdHelper::ConfigGenerator.generate_from_hash({
        "Unit" => {
          "Description" => "Fan Control",
          "After" => "ipmievd.service"
        },
        "Service" => {
          "Type" => "oneshot",
          "ExecStart" => [
            "/usr/bin/ipmitool raw 0x30 0x70 0x66 0x01 0x00 0x18",
            "/usr/bin/ipmitool raw 0x30 0x70 0x66 0x01 0x01 0x18"
          ]
        },
        "Install" => {
          "WantedBy" => "multi-user.target"
        }
      })
    },
    {
      # systemd networks
      ## lan network
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
    {
      ## store
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
    {
      ## allow guests to access the host over macvlan
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
    {
      ## wan
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
    {
      ## zfssync
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
    {
      # enable serial console
      "path" => '/etc/default/grub',
      "data" => <<-EOF
GRUB_TERMINAL="console serial"
GRUB_SERIAL_COMMAND="serial --unit=1 --speed=115200 --word=8 --parity=no --stop=1"
EOF
    },
    {
      # load NIC VFs
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
    {
      # DNF automatic
      "path" => '/etc/dnf/automatic.conf',
      "data" => <<-EOF
[commands]
apply_updates = true
upgrade_type = security
[emitters]
emit_via = motd
EOF
    },
    {
      # SSH
      "path" => '/etc/ssh/sshd_config',
      "data" => <<-EOF
Subsystem sftp internal-sftp
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
EOF
    },
    {
      # etcd configs
      "path" => '/etc/etcd/etcd.conf',
      "data" => {
        "ETCD_NAME" => host,
        "ETCD_DATA_DIR" => "/data/etcd/#{node['etcd']['cluster_name']}",

        "ETCD_INITIAL_ADVERTISE_PEER_URLS" => "https://#{ip}:2380",
        "ETCD_LISTEN_PEER_URLS" => "https://#{ip}:2380",
        "ETCD_ADVERTISE_CLIENT_URLS" => "https://#{ip}:2379",
        "ETCD_LISTEN_CLIENT_URLS" => "https://#{ip}:2379,http://127.0.0.1:2379",
        "ETCD_INITIAL_CLUSTER" => etcd_initial_cluster,
        "ETCD_INITIAL_CLUSTER_STATE" => "new",
        "ETCD_INITIAL_CLUSTER_TOKEN" => node['etcd']['cluster_name'],

        "ETCD_TRUSTED_CA_FILE" => node['etcd']['ca_path'],
        "ETCD_CERT_FILE" => node['etcd']['cert_path'],
        "ETCD_KEY_FILE" => node['etcd']['key_path'],

        "ETCD_PEER_TRUSTED_CA_FILE" => node['etcd']['ca_peer_path'],
        "ETCD_PEER_CERT_FILE" => node['etcd']['cert_peer_path'],
        "ETCD_PEER_KEY_FILE" => node['etcd']['key_peer_path'],

        "ETCD_PEER_CLIENT_CERT_AUTH" => true
      }.map { |k, v| "#{k}=#{v}" }.join($/)
    },
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
    }
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
      files: files,
      services_enable: node['kickstart']['vmhost']['services_enable'],
    })
  end

end
