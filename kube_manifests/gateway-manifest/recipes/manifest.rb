keepalived_bag = Dbag::Keystore.new('deploy_config', 'keepalived')

haproxy_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "haproxy"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "haproxy",
        "image" => node['kube']['images']['haproxy'],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => node['kube_manifests']['gateway']['haproxy_config']
          }
        ]
      }
    ]
  }
}


node['kube_manifests']['gateway']['hosts'].each do |host|

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
        'notify_master' => %Q{"/sbin/ip link set #{node['environment_v2']['host'][host]['if_wan']} up"},
        'notify_backup' => %Q{"/sbin/ip link set #{node['environment_v2']['host'][host]['if_wan']} down"},
        'notify_fault' => %Q{"/sbin/ip link set #{node['environment_v2']['host'][host]['if_wan']} down"},
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
          "#{node['environment_v2']['set']['gateway']['vip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
        ]
      }
    ]
  })

  gateway_manifest = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      "name" => "keepalived"
    },
    "spec" => {
      "restartPolicy" => "Always",
      "hostNetwork" => true,
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

  node.default['kubernetes']['static_pods'][host]['gateway.yaml'] = gateway_manifest
  node.default['kubernetes']['static_pods'][host]['haproxy_manifest.yaml'] = haproxy_manifest
end
