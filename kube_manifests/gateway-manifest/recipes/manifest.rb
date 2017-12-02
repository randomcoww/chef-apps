keepalived_bag = Dbag::Keystore.new('deploy_config', 'keepalived')
vip_subnet = node['environment_v2']['subnet']['lan'].split('/').last

vip_haproxy = node['environment_v2']['set']['haproxy']['vip_lan']

node['environment_v2']['set']['gateway']['hosts'].each do |host|


  if_lan = node['environment_v2']['host'][host]['if_lan']
  if_wan = node['environment_v2']['host'][host]['if_wan']

  nftables_rules = <<-EOF
define host_if_lan = #{if_lan}
define host_if_wan = #{if_wan}
define vip_haproxy = #{vip_haproxy}

table ip filter {
  chain input {
    type filter hook input priority 0; policy drop;

    ct state {established, related} accept;
    ct state invalid drop;

    iifname {lo, $host_if_lan} accept;
    iifname != "lo" ip daddr 127.0.0.1/8 drop;

    iifname $host_if_lan ip protocol icmp accept;
    iifname $host_if_lan udp sport bootps udp dport bootpc accept;
    iifname $host_if_lan pkttype multicast accept;
    iifname $host_if_lan tcp dport ssh accept;
  }

  chain output {
    type filter hook output priority 100; policy accept;
  }

  chain forward {
    type filter hook forward priority 0; policy drop;
    iifname $host_if_lan oifname $host_if_wan accept;
    iifname $host_if_wan oifname $host_if_lan ct state {established, related} accept;

    iifname $host_if_wan oifname $host_if_lan ip daddr $vip_haproxy tcp dport 2222 ct state new accept;
  }
}

table ip nat {
  chain prerouting {
    type nat hook prerouting priority 0; policy accept;

    iifname $host_if_wan tcp dport 2222 dnat $vip_haproxy:2222;
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


  keepalived_config = KeepalivedHelper::ConfigGenerator.generate_from_hash({
    'vrrp_sync_group VG_gateway' => [
      {
        'group' => [
          'VI_gateway'
        ]
      }
    ],
    'vrrp_instance VI_gateway' => [
      {
        'state' => 'BACKUP',
        # 'notify_master' => %Q{"/sbin/ip link set #{node['environment_v2']['host'][host]['if_wan']} up"},
        # 'notify_backup' => %Q{"/sbin/ip link set #{node['environment_v2']['host'][host]['if_wan']} down"},
        # 'notify_fault' => %Q{"/sbin/ip link set #{node['environment_v2']['host'][host]['if_wan']} down"},
        'virtual_router_id' => 80,
        'interface' => node['environment_v2']['host'][host]['if_lan'],
        'priority' => 100,
        'authentication' => [
          {
            'auth_type' => 'AH',
            'auth_pass' => keepalived_bag.get_or_create('VI_gateway_v2', SecureRandom.base64(6))
          }
        ],
        'virtual_ipaddress' => [
          "#{node['environment_v2']['set']['gateway']['vip_lan']}/#{vip_subnet}",
          "#{node['environment_v2']['set']['ns']['vip_lan']}/#{vip_subnet}"
        ]
      }
    ]
  })

  keepalived_manifest = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      "name" => "keepalived"
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
          "name" => "keepalived",
          "image" => node['kube']['images']['keepalived'],
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
              "value" => keepalived_config
            }
          ]
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['keepalived.yaml'] = keepalived_manifest
  # node.default['kubernetes']['static_pods'][host]['nftables_sync.yaml'] = gitsync_manifest
  # node.default['kubernetes']['static_pods'][host]['kube_apiserver_manifest.yaml'] = kube_apiserver_manifest
end
