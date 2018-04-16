node.default['kube_manifests']['transmission']['nftables_config'] = <<-EOF
table ip filter {
  chain output {
    type filter hook output priority 30; policy drop;
    ct state { established, related } accept
    oifname "tun*" accept
    skgid { "root" } accept
    ip daddr { 192.168.0.0/16, 10.3.0.0/24, 10.244.0.0/16 } accept
  }
}
;
EOF
