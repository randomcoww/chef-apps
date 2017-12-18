node['environment_v2']['set']['gateway']['hosts'].each do |host|

  if_lan = node['environment_v2']['host'][host]['if']['lan']
  if_store = node['environment_v2']['host'][host]['if']['store']
  if_wan = node['environment_v2']['host'][host]['if']['wan']
  vip_haproxy = node['environment_v2']['set']['haproxy']['vip']['store']

  ##https://stosb.com/blog/explaining-my-configs-nftables/

  nftables_rules =
<<-EOF
define if_lan = #{if_lan}
define if_store = #{if_store}
define if_internal = {#{if_lan}, #{if_store}}
define if_external = #{if_wan}
define ip_lb = #{vip_haproxy}


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
    # iifname $if_internal pkttype multicast accept;
    iifname $if_internal tcp dport ssh accept;
  }

  chain forward {
    type filter hook forward priority 0; policy drop;

    jump base_checks;

    ip protocol icmp icmp type { echo-request, echo-reply, time-exceeded, parameter-problem, destination-unreachable } accept;

    iifname $if_internal oifname $if_external accept;

    iifname $if_internal tcp dport @tcp_fwd accept;
    iifname $if_internal udp dport @udp_fwd accept;

    iifname $if_internal ip daddr $ip_lb accept;
    ip daddr $ip_lb ct status dnat accept;
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

    tcp dport @tcp_dnat dnat $ip_lb;
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

  gateway_manifest = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      "name" => "nftables"
    },
    "spec" => {
      "restartPolicy" => "OnFailure",
      "hostNetwork" => true,
      "containers" => [
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
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['gateway'] = gateway_manifest
end
