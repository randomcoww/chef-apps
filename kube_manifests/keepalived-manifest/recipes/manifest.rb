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

    host_config = node['environment_v2']['host'][host]

    configs[host]['global_defs'] = [
      {
        'vrrp_version' => 3
      }
    ]

    configs[host]["vrrp_sync_group VG_#{set}"] = [
      {
        'group' => sync_groups
      }
    ]

    if host_config.has_key?('notify_scripts')
      configs[host]["vrrp_sync_group VG_#{set}"] += host_config['notify_scripts']
    end

    c['vip'].each do |i, addr|
      key = "#{set}_#{i}"
      interface = host_config['if'][i]
      subnet_mask = node['environment_v2']['subnet'][i].split('/').last

      id = keepalived_bag.get_or_create("VI_#{key}_id", rand(255))

      sync_groups << "VI_#{key}"

      instance = {
        'state' => 'BACKUP',
        'strict_mode' => 'off',
        'virtual_router_id' => id,
        'interface' => interface,
        'priority' => 100,
        'virtual_ipaddress' => [
          "#{addr}/#{subnet_mask}"
        ]
      }

      if c.has_key?('health_check')
        configs[host]["vrrp_script CHK_#{set}"] = [
          {
            'script' => %Q{"#{c["health_check"]}"},
            'interval' => 2
          }
        ]

        instance['track_script'] = [
          "CHK_#{set}"
        ]
      end

      configs[host]["vrrp_instance VI_#{key}"] = [
        instance,
        # "use_vmac vrrp#{id}",
        # "vmac_xmit_base"
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
