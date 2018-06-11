node['environment_v2']['set']['gateway']['hosts'].each do |host|

  if_lan = node['environment_v2']['host'][host]['if']['lan']
  if_store = node['environment_v2']['host'][host]['if']['store']
  if_wan = node['environment_v2']['host'][host]['if']['wan']
  if_sync = node['environment_v2']['host'][host]['if']['sync']

  vip_haproxy = node['environment_v2']['set']['haproxy']['vip']['store']
  vip_apiserver = node['environment_v2']['set']['kube-master']['vip']['store']

  ##https://stosb.com/blog/explaining-my-configs-nftables/

  nftables_rules =
<<-EOF
define if_lan = #{if_lan}
define if_store = #{if_store}
define if_sync = #{if_sync}
define if_internal = {#{if_lan}, #{if_store}, #{if_sync}}
define if_external = #{if_wan}

define vip_haproxy = #{vip_haproxy}
define vip_apiserver = #{vip_apiserver}

table ip filter {
  chain base_checks {
    ct state {established, related} accept;
    ct state invalid drop;
  }

  set tcp_fwd {
    type inet_service; flags interval;
    elements = {
      ssh,
      sunrpc,nfs
    }
  }

  set udp_fwd {
    type inet_service; flags interval;
    elements = {
      sunrpc,nfs
    }
  }

  chain input {
    type filter hook input priority 0; policy drop;

    jump base_checks;

    iifname "lo" accept;
    iifname != "lo" ip daddr 127.0.0.1/8 drop;

    ip protocol icmp icmp type { echo-request, echo-reply, time-exceeded, parameter-problem, destination-unreachable } accept;

    iifname $if_store accept;

    iifname $if_internal tcp dport domain accept;
    iifname $if_internal udp dport domain accept;
    iifname $if_internal udp sport bootps udp dport bootpc accept;
    iifname $if_internal pkttype multicast accept;
    iifname $if_internal tcp dport ssh accept;
  }

  chain forward {
    type filter hook forward priority 0; policy drop;

    jump base_checks;

    ip protocol icmp icmp type { echo-request, echo-reply, time-exceeded, parameter-problem, destination-unreachable } accept;

    iifname $if_internal oifname $if_external accept;

    iifname $if_internal tcp dport @tcp_fwd accept;
    iifname $if_internal udp dport @udp_fwd accept;

    iifname $if_internal ip daddr $vip_haproxy accept;
    iifname $if_internal ip daddr $vip_apiserver accept;

    ip daddr $vip_apiserver ct status dnat accept;
  }

  chain output {
    type filter hook output priority 100; policy accept;
  }
}

table ip nat {
  set tcp_dnat {
    type inet_service; flags interval;
    elements = {
      2222
    }
  }

  chain prerouting {
    type nat hook prerouting priority 0; policy accept;
    tcp dport @tcp_dnat dnat $vip_apiserver;
  }

  chain input {
    type nat hook input priority 0; policy accept;
  }

  chain output {
    type nat hook output priority 0; policy accept;
  }

  chain postrouting {
    type nat hook postrouting priority 100; policy accept;
    oifname $if_external masquerade;
  }
}
;
EOF


  conntrack_config = KeepalivedHelper::ConfigGenerator.generate_from_hash({
    "Sync" => [
      {
        "Mode FTFW" => [
          "DisableExternalCache" => "on"
        ],
        "Multicast Default" => [
          {
            "IPv4_address" => "225.0.0.51",
            "Group" => 3781,
            # "IPv4_interface" => node['environment_v2']['host'][host]['ip']['sync'],
            "Interface" => if_sync,
            "SndSocketBuffer" => 1249280,
            "RcvSocketBuffer" => 1249280,
            "Checksum" => "on",
          }
        ]
      }
    ],
    "General" => [
      {
        "HashSize" => 32768,
        "HashLimit" => 131072,
        "LogFile" => "/dev/stdout",
        "LockFile" => "/var/lock/conntrack.lock",
        "NetlinkBufferSize" => 2097152,
        "NetlinkBufferSizeMaxGrowth" => 8388608,
        "UNIX" => [
          {
            "Path" => "/var/run/conntrackd.ctl",
            "Backlog" => 20
          }
        ],
        "Filter From Kernelspace" => [
          {
            # "Protocol Accept" => [
            #   "icmp",
            #   "TCP",
            #   "UDP",
            # ],
            "Address Ignore" => ([
              "127.0.0.1",
            ] +
              # node['environment_v2']['host'][host]['ip'].values +
              node['environment_v2']['set']['gateway']['vip'].values
            ).map { |e| "IPv4_address #{e}" }
          }
        ]
      }
    ]
  })


  gateway_manifest = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      "name" => "nftables"
    },
    "spec" => {
      "restartPolicy" => "Always",
      "hostNetwork" => true,
      "initContainers" => [
        {
          "name" => "nftables",
          "image" => node['kube']['images']['nftables'],
          "securityContext" => {
            "capabilities" => {
              "add" => [
                "NET_ADMIN"
              ]
            }
          },
          "env" => [
            {
              "name" => "CONFIG",
              "value" => nftables_rules
            }
          ]
        }
      ],
      "containers" => [
        {
          "name" => "conntrack",
          "image" => node['kube']['images']['conntrack'],
          "securityContext" => {
            "capabilities" => {
              "add" => [
                "NET_ADMIN"
              ]
            }
          },
          "env" => [
            {
              "name" => "CONFIG",
              "value" => conntrack_config
            }
          ]
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['gateway'] = gateway_manifest
end
