node.default['kube_manifests']['gateway']['nftables_config'] = <<-EOF
table ip filter {
  chain input {
    type filter hook input priority 0; policy drop;

    ct state {established, related} accept;
    ct state invalid drop;

    iifname {lo, $host_if_lan, $host_if_store} accept;
    iifname != "lo" ip daddr 127.0.0.1/8 drop;

    iifname {$host_if_lan, $host_if_store} ip protocol icmp accept;
    iifname {$host_if_lan, $host_if_store} udp sport bootps udp dport bootpc accept;
    iifname {$host_if_lan, $host_if_store} pkttype multicast accept;

    iifname {$host_if_lan, $host_if_store} tcp dport ssh accept;
  }

  chain output {
    type filter hook output priority 100; policy accept;
  }

  chain forward {
    type filter hook forward priority 0; policy drop;
    iifname {$host_if_lan, $host_if_store} oifname $host_if_wan accept;
    iifname $host_if_wan oifname {$host_if_lan, $host_if_store} ct state {established, related} accept;

    iifname $host_if_wan oifname $host_if_store ip daddr $vip_haproxy_store tcp dport 2222 ct state new accept;

    iifname $host_if_store oifname $host_if_lan accept;
    iifname $host_if_lan oifname $host_if_store accept;
  }
}

table ip nat {
  chain prerouting {
    type nat hook prerouting priority 0; policy accept;

    iifname $host_if_wan tcp dport 2222 dnat $vip_haproxy_store:2222;
  }

  chain input {
    type nat hook input priority 0; policy accept;
  }

  chain output {
    type nat hook output priority 0; policy accept;
  }

  chain postrouting {
    type nat hook postrouting priority 100; policy accept;
    oifname $host_if_wan masquerade;
  }
}
;
EOF
