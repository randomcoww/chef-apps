keepalived_bag = Dbag::Keystore.new('deploy_config', 'keepalived')
vip_subnet = node['environment_v2']['subnet']['lan'].split('/').last

node['environment_v2']['set']['gateway']['hosts'].each do |host|

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
          "#{node['environment_v2']['set']['gateway']['vip_lan']}/#{vip_subnet}"
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

  # gitsync_manifest = {
  #   "apiVersion": "v1",
  #   "kind": "Pod",
  #   "metadata": {
  #     "name": "nftables-sync"
  #   },
  #   "spec": {
  #     "restartPolicy" => "Always",
  #     "hostNetwork" => true,
  #     "containers": [
  #       {
  #         "name": "git-sync",
  #         "image": "gcr.io/google_containers/git-sync:v2.0.4",
  #         "imagePullPolicy": "Always",
  #         "volumeMounts": [
  #           {
  #             "name": "nftables",
  #             "mountPath": "/git"
  #           }
  #         ],
  #         "args" => [
  #           "--root=/git",
  #           "--dest=rules",
  #           "--repo=https://github.com/randomcoww/nftables-config.git",
  #           "--branch=master",
  #           "--wait=30"
  #         ]
  #       }
  #     ],
  #     "volumes": [
  #       {
  #         "name": "nftables",
  #         "hostPath" => {
  #           "path" => node['environment_v2']['nftables']['load_path']
  #         }
  #       }
  #     ]
  #   }
  # }


  node.default['kubernetes']['static_pods'][host]['keepalived.yaml'] = keepalived_manifest
  # node.default['kubernetes']['static_pods'][host]['nftables_sync.yaml'] = gitsync_manifest
  # node.default['kubernetes']['static_pods'][host]['kube_apiserver_manifest.yaml'] = kube_apiserver_manifest
end
