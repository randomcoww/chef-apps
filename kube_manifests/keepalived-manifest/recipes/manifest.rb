keepalived_bag = Dbag::Keystore.new('deploy_config', 'keepalived')
configs = {}

node['environment_v2']['set'].each do |set, c|

  if !c['hosts'].is_a?(Array) ||
    !c['vip'].is_a?(Hash)

    next
  end

  c['hosts'].each do |host|

    configs[host] ||= {}
    sync_groups = []

    configs[host]["vrrp_sync_group VG_#{set}"] = [
      {
        'group' => sync_groups
      }
    ]

    c['vip'].each do |i, addr|
      key = "#{set}_#{i}"
      interface = node['environment_v2']['host'][host]['if'][i]
      subnet_mask = node['environment_v2']['subnet'][i].split('/').last

      id = keepalived_bag.get_or_create("VI_#{key}_id", rand(255))
      password = keepalived_bag.get_or_create("VI_#{key}_password", SecureRandom.base64(6))

      sync_groups << "VI_#{key}"

      configs[host]["vrrp_instance VI_#{key}"] = [
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
          'virtual_ipaddress' => [
            "#{addr}/#{subnet_mask}"
          ]
        }
      ]
    end
  end
end


configs.each do |host, config|
  keepalived_manifest = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      "namespace" => "kube-system",
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
          "args" => [
            "-P"
          ],
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
