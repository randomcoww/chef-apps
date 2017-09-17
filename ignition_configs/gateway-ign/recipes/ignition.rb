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

nftables_path = "/etc/nft.rules"

sysctl_config = [
  "net.ipv4.ip_forward=1",
  "net.ipv4.ip_nonlocal_bind=1"
].join($/)


node['ignition']['gateway']['hosts'].each do |host|

  ip_lan = node['environment_v2']['host'][host]['ip_lan']
  if_lan = node['environment_v2']['host'][host]['if_lan']
  if_wan = node['environment_v2']['host'][host]['if_wan']

  t = Tempfile.new('/tmp')
  template t.path do
    source 'nft.erb'
    variables ({
      current_host: node['environment_v2']['host'][host],
      sets: node['environment_v2']['set'],
      hosts: node['environment_v2']['host']
    })
    action :nothing
  end.run_action(:create)
  t.close

  nftables_config = IO.binread(t.path).gsub(/\t/, "  ")

  files = [
    {
      "path" => "/etc/hostname",
      "mode" => 420,
      "contents" => "data:,#{host}"
    },
    {
      "path" => nftables_path,
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(nftables_config)}"
    },
    {
      "path" => "/etc/sysctl.d/ipforward.conf",
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(sysctl_config)}"
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
          "DHCP" => "no"
        },
        "Address" => {
          "Address" => "#{ip_lan}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
        },
        "Route" => {
          "Gateway" => node['environment_v2']['set']['gateway']['vip_lan'],
          "Metric" => 2048
        }
      }
    },
    {
      "name" => if_wan,
      "contents" => {
        "Match" => {
          "Name" => if_wan
        },
        "Network" => {
          "LinkLocalAddressing" => "no",
          "DHCP" => "yes",
          "DNS" => (node['environment_v2']['set']['dns']['hosts'].map { |h|
            node['environment_v2']['host'][h]['ip_lan']
          } + [ '8.8.8.8' ])
        },
        "DHCP" => {
          "UseDNS" => "false",
          "UseNTP" => "false",
          "SendHostname" => "false",
          "UseHostname" => "false",
          "UseDomains" => "false",
          "UseTimezone" => "no",
          "RouteMetric" => 1024,
          # "IPMasquerade" => "yes",
          # "IPForward" => "ipv4"
        }
      }
    }
  ]

  systemd = [
    {
      "name" => "kubelet",
      "contents" => {
        "Service" => {
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
            # "--api-servers=http://127.0.0.1:8080",
            "--register-schedulable=false",
            "--register-node=true",
            "--cni-conf-dir=/etc/kubernetes/cni/net.d",
            # "--network-plugin=${NETWORK_PLUGIN}",
            "--container-runtime=docker",
            "--allow-privileged=true",
            "--manifest-url=http://#{node['environment_v2']['current_host']['ip_lan']}:8888/manifests/#{host}",
            # "--hostname-override=#{ip_lan}",
            "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
            "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
            "--make-iptables-util-chains=false"
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
      "name" => "docker",
      "dropins" => [
        {
          "name" => "iptables",
          "contents" => {
            "Service" => {
              "Environment" => [
                "DOCKER_OPTS=--iptables=false"
              ]
            }
          }
        }
      ]
    },
    {
      "name" => "nftables",
      "contents" => {
        "Unit" => {
          "Wants" => "network-pre.target",
          "Before" => "network-pre.target"
        },
        "Service" => {
          "Type" => "oneshot",
          "ExecStartPre" => "-/usr/sbin/nft flush ruleset",
          "ExecStart" => "/usr/sbin/nft -f #{nftables_path}",
          "ExecStop" => "/usr/sbin/nft flush ruleset",
          "RemainAfterExit" => "yes"
        },
        "Install" => {
          "WantedBy" => "multi-user.target"
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
