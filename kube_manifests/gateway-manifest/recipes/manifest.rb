keepalived_bag = Dbag::Keystore.new('deploy_config', 'keepalived')

# kube_apiserver_manifest = {
#   "kind" => "Pod",
#   "apiVersion" => "v1",
#   "metadata" => {
#     "namespace" => "kube-system",
#     "name" => "kube-apiserver"
#   },
#   "spec" => {
#     "hostNetwork" => true,
#     "restartPolicy" => 'Always',
#     "containers" => [
#       {
#         "name" => "kube-apiserver",
#         "image" => node['kube']['images']['hyperkube'],
#         "command" => [
#           "/hyperkube",
#           "apiserver",
#           "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
#           "--etcd-servers=http://#{node['environment_v2']['set']['haproxy']['vip_lan']}:#{node['environment_v2']['service']['etcd-client']['port']}",
#           "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds",
#           "--allow-privileged=true"
#         ],
#         "livenessProbe" => {
#           "httpGet" => {
#             "scheme" => "HTTP",
#             "host" => "127.0.0.1",
#             "port" => node['kubernetes']['insecure_port'],
#             "path" => "/healthz"
#           },
#           "initialDelaySeconds" => 15,
#           "timeoutSeconds" => 15
#         }
#       }
#     ]
#   }
# }


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
          "#{node['environment_v2']['set']['gateway']['vip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
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

  node.default['kubernetes']['static_pods'][host]['keepalived.yaml'] = keepalived_manifest
  # node.default['kubernetes']['static_pods'][host]['kube_apiserver_manifest.yaml'] = kube_apiserver_manifest
end
