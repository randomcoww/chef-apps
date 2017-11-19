haproxy_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    # "namespace" => "kube-system",
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
            "value" => node['kube_manifests']['haproxy']['haproxy_config']
          }
        ]
      }
    ]
  }
}

keepalived_bag = Dbag::Keystore.new('deploy_config', 'keepalived')
vip_subnet = node['environment_v2']['subnet']['lan'].split('/').last

node['environment_v2']['set']['haproxy']['hosts'].each do |host|

  keepalived_config = KeepalivedHelper::ConfigGenerator.generate_from_hash({
    'vrrp_sync_group VG_kube' => [
      {
        'group' => [
          'VI_kube'
        ]
      }
    ],
    'vrrp_instance VI_kube' => [
      {
        'state' => 'BACKUP',
        'virtual_router_id' => 81,
        'interface' => node['environment_v2']['host'][host]['if_lan'],
        'priority' => 100,
        'authentication' => [
          {
            'auth_type' => 'AH',
            'auth_pass' => keepalived_bag.get_or_create('VI_kube', SecureRandom.base64(6))
          }
        ],
        'virtual_ipaddress' => [
          "#{node['environment_v2']['set']['haproxy']['vip_lan']}/#{vip_subnet}"
        ]
      }
    ]
  })

  keepalived_manifest = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      # "namespace" => "kube-system",
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

  node.default['kubernetes']['static_pods'][host]['haproxy_manifest.yaml'] = haproxy_manifest
  node.default['kubernetes']['static_pods'][host]['keepalived.yaml'] = keepalived_manifest
end
