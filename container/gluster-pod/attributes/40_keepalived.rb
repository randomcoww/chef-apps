dbag = Dbag::Keystore.new('deploy_config', 'keepalived')

node.default['kubelet']['keepalived']['config'] = KeepalivedHelper::ConfigGenerator.generate_from_hash({
  'vrrp_sync_group VG_gluster' => [
    {
      'group' => [
        'VI_lan_gluster',
        'VI_store_gluster'
      ]
    }
  ],
  'vrrp_instance VI_lan_gluster' => [
    'use_vmac',
    'vmac_xmit_base',
    {
      'state' => 'BACKUP',
      'virtual_router_id' => 23,
      'interface' => node['environment_v2']['current_host']['if_lan'],
      'priority' => 100,
      'authentication' => [
        {
          'auth_type' => 'AH',
          'auth_pass' => dbag.get_or_create('VI_lan_gluster', SecureRandom.base64(6))
        }
      ],
      'virtual_ipaddress' => [
        "#{node['environment_v2']['set']['gluster']['vip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
      ]
    }
  ],
  'vrrp_instance VI_store_gluster' => [
    'use_vmac',
    'vmac_xmit_base',
    {
      'state' => 'BACKUP',
      'virtual_router_id' => 24,
      'interface' => node['environment_v2']['current_host']['if_store'],
      'priority' => 100,
      'authentication' => [
        {
          'auth_type' => 'AH',
          'auth_pass' => dbag.get_or_create('VI_store_gluster', SecureRandom.base64(6))
        }
      ],
      'virtual_ipaddress' => [
        "#{node['environment_v2']['set']['gluster']['vip_store']}/#{node['environment_v2']['subnet']['store'].split('/').last}"
      ]
    }
  ]
})
