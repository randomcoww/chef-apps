## host to vip mapping
host_to_vip_map = {}
host_to_set_map = {}

node['environment_v2']['set'].each do |k, v|

  if k['vip'].is_a?(Hash)

    if v['hosts'].is_a?(Array)
      v['hosts'].each do |h|

        host_to_set_map[h] = k
        host_to_vip_map[h] ||= {}

        ## combine like interfaces
        k['vip'].each do |i, addr|
          host_to_vip_map[h][i] ||= []
          host_to_vip_map[h][i] << addr
        end
      end
    end
  end
end


keepalived_bag = Dbag::Keystore.new('deploy_config', 'keepalived')

host_to_vip_map.each do |h, m|

  config = {}
  m.each do |i, addrs|

    set = "#{h}_#{i}"
    subnet_mask = node['environment_v2']['subnet'][i].split('/').last
    id = keepalived_bag.get_or_create("VI_#{set}_id", rand(255))
    password = keepalived_bag.get_or_create("VI_#{set}_password", SecureRandom.base64(6))
    interface = node['environment_v2']['host']['if'][i]


    config["vrrp_sync_group VG_#{set}"] = [
      {
        'group' => [
          "VI_#{set}"
        ]
      }
    ]

    config["vrrp_sync_group VG_#{set}"] = [
      {
        'state' => 'BACKUP',
        'virtual_router_id' => id,
        'interface' => interface,
        'priority' => 100,
        'authentication' => [
          {
            'auth_type' => 'AH',
            'auth_pass' => password
          }
        ],
        'virtual_ipaddress' => addrs.map { |e|
          "#{e}/#{subnet_mask}"
        }
      }
    ]
  end

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
              "value" => KeepalivedHelper::ConfigGenerator.generate_from_hash(config)
            }
          ]
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['keepalived'] = keepalived_manifest
end
