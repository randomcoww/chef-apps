dbag = Dbag::Keystore.new('deploy_config', 'keepalived')

node.default['kubelet']['keepalived']['config'] = KeepalivedHelper::ConfigGenerator.generate_from_hash({
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
      'notify_master' => %Q{"/sbin/ip link set #{node['environment_v2']['current_host']['if_wan']} up"},
      'notify_backup' => %Q{"/sbin/ip link set #{node['environment_v2']['current_host']['if_wan']} down"},
      'notify_fault' => %Q{"/sbin/ip link set #{node['environment_v2']['current_host']['if_wan']} down"},
      'virtual_router_id' => 20,
      'interface' => node['environment_v2']['current_host']['if_lan'],
      'priority' => 100,
      'authentication' => [
        {
          'auth_type' => 'AH',
          'auth_pass' => dbag.get_or_create('VI_gateway', SecureRandom.base64(6))
        }
      ],
      'virtual_ipaddress' => [
        "#{node['environment_v2']['set']['gateway']['vip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
      ]
    }
  ]
})
