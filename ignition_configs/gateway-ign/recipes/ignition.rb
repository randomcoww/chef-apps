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


sysctl_config = [
  "net.ipv4.ip_forward=1",
  "net.ipv4.ip_nonlocal_bind=1"
].join($/)


node['environment_v2']['set']['gateway']['hosts'].uniq.each do |host|

  directories = [
    # {
    #   "path" => node['environment_v2']['nftables']['load_path'],
    #   "mode" => 511
    # }
  ]

  files = [
    {
      "path" => "/etc/hostname",
      "mode" => 420,
      "contents" => "data:,#{host}"
    },
    ## sysctl
    {
      "path" => "/etc/sysctl.d/ipforward.conf",
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(sysctl_config)}"
    }
  ]


  networkd = []

  interfaces = node['environment_v2']['host'][host]['if'].to_hash.dup

  wan_interface = interfaces.delete('wan')
  if !wan_interface.nil?

    networkd << {
      "name" => "#{wan_interface}.network",
      "contents" => {
        "Match" => {
          "Name" => wan_interface
        },
        "Network" => {
          "LinkLocalAddressing" => "no",
          "DHCP" => "yes"
        },
        "DHCP" => {
          "UseDNS" => "false",
          "UseNTP" => "false",
          ## failing with new coreos
          # "Anonymize" => "true",
          "SendHostname" => "false",
          "UseHostname" => "false",
          "UseDomains" => "false",
          "UseTimezone" => "no",
          "RouteMetric" => 1024
        }
      }
    }
  end

  if node['environment_v2']['host'][host]['ip'].is_a?(Hash)
    interfaces.each do |i, interface|

      addr = node['environment_v2']['host'][host]['ip'][i]

      if !interface.nil? &&
        !addr.nil?

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
            }
          }
        }
      end
    end
  end


  systemd = [
    {
      "name" => "kubelet.service",
      "contents" => {
        "Service" => {
          "Environment" => [
            "KUBELET_IMAGE_TAG=v#{node['kubernetes']['version']}_coreos.0",
            %Q{RKT_RUN_ARGS="#{[
              "--uuid-file-save=/var/run/kubelet-pod.uuid",
              "--volume var-log,kind=host,source=/var/log",
              "--mount volume=var-log,target=/var/log",
              "--volume dns,kind=host,source=/etc/resolv.conf",
              "--mount volume=dns,target=/etc/resolv.conf",
            ].join(' ')}"}
          ],
          "ExecStartPre" => [
            "/usr/bin/mkdir -p /etc/kubernetes/manifests",
            "/usr/bin/mkdir -p /var/log/containers",
            "-/usr/bin/rkt rm --uuid-file=/var/run/kubelet-pod.uuid"
          ],
          "ExecStart" => [
            "/usr/lib/coreos/kubelet-wrapper",
            "--register-node=true",
            "--cni-conf-dir=#{::File.dirname(node['kubernetes']['cni_conf_path'])}",
            "--container-runtime=docker",
            "--allow-privileged=true",
            "--manifest-url=#{node['environment_v2']['url']['manifests']}/#{host}",
            "--make-iptables-util-chains=false",
            "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
            "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
            "--docker-disable-shared-pid=false",
            "--image-gc-high-threshold=0",
            "--image-gc-low-threshold=0",
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
      "name" => "docker.service",
      "dropins" => [
        {
          "name" => "iptables.conf",
          "contents" => {
            "Service" => {
              "Environment" => [
                "DOCKER_OPTS=--iptables=false"
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
