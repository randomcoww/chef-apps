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

  ip_lan = node['environment_v2']['host'][host]['ip_lan']
  if_lan = node['environment_v2']['host'][host]['if_lan']
  if_wan = node['environment_v2']['host'][host]['if_wan']


  ##
  ## nftables
  ##

  nftables_load_rules = File.join(node['environment_v2']['nftables']['load_path'], 'rules', host)
  nftables_rules = []
  nftables_defines = {}

  node['environment_v2']['set'].each do |k, v|
    case v
    when Hash
      if !v['vip_lan'].nil?
        nftables_defines["vip_#{k}"] = v['vip_lan']
      end
    end
  end

  node['environment_v2']['host'][host].each do |k, v|
    case v
    when String,Integer
      nftables_defines["host_#{k}"] = v
    end
  end

  nftables_defines.each do |k, v|
    nftables_rules << "define #{k.gsub('-', '_')} = #{v}"
  end

  nftables_rules << %Q{include "#{nftables_load_rules}"}
  nftables_rules << ''


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
    ## nftables
    {
      "path" => node['environment_v2']['nftables']['defines_rules'],
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(nftables_rules.join($/))}"
    },
    {
      "path" => nftables_load_rules,
      "mode" => 420,
      "contents" => "#{node['environment_v2']['url']['nftables']}/#{host}"
    },
    ## sysctl
    {
      "path" => "/etc/sysctl.d/ipforward.conf",
      "mode" => 420,
      "contents" => "data:;base64,#{Base64.encode64(sysctl_config)}"
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
          "DHCP" => "no",
          "DNS" => [
            '127.0.0.1',
            '8.8.8.8'
          ]
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
      "name" => "#{if_wan}.network",
      "contents" => {
        "Match" => {
          "Name" => if_wan
        },
        "Network" => {
          "LinkLocalAddressing" => "no",
          "DHCP" => "yes"
        },
        "DHCP" => {
          "UseDNS" => "false",
          "UseNTP" => "false",
          "Anonymize" => "true",
          "SendHostname" => "false",
          "UseHostname" => "false",
          "UseDomains" => "false",
          "UseTimezone" => "no",
          "RouteMetric" => 1024
        }
      }
    }
  ]

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
            "--cni-conf-dir=/etc/kubernetes/cni/net.d",
            "--container-runtime=docker",
            "--allow-privileged=true",
            "--manifest-url=#{node['environment_v2']['url']['manifests']}/#{host}",
            "--make-iptables-util-chains=false",
            "--cluster_dns=#{node['kubernetes']['cluster_dns_ip']}",
            "--cluster_domain=#{node['kubernetes']['cluster_domain']}",
            "--docker-disable-shared-pid=false"
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
    },
    {
      "name" => "nftables.service",
      "contents" => {
        "Unit" => {
          "Wants" => "network-pre.target",
          "Before" => "network-pre.target",
          # "ConditionPathExists" => nftables_load_rules
        },
        "Service" => {
          "Type" => "oneshot",
          "ExecStartPre" => "-/usr/sbin/nft flush ruleset",
          "ExecStart" => "/usr/sbin/nft -f #{node['environment_v2']['nftables']['defines_rules']}"
        },
        "Install" => {
          "WantedBy" => "multi-user.target"
        }
      }
    },
    {
      "name" => "nftables.path",
      "contents" => {
        # "Unit" => {
        #   "Wants" => "network-pre.target",
        #   "Before" => "network-pre.target",
        #   "ConditionPathExists" => nftables_load_rules
        # },
        "Path" => {
          "PathChanged" => nftables_load_rules,
          "PathExists" => nftables_load_rules
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
    'directories' => directories,
    'networkd' => networkd,
    'systemd' => systemd
  }

end
