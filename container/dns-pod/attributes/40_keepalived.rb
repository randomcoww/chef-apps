dbag = Dbag::Keystore.new('deploy_config', 'keepalived')
password = dbag.get_or_create('VI_dns', SecureRandom.base64(6))

node.default['kubelet']['keepalived']['config'] = KeepalivedHelper::ConfigGenerator.generate_from_hash({
  'vrrp_sync_group VG_dns' => [
    {
      'group' => [
        'VI_dns'
      ]
    }
  ],
  'vrrp_instance VI_dns' => [
    {
      'state' => 'BACKUP',
      'virtual_router_id' => 22,
      'interface' => node['environment_v2']['current_host']['if_lan'],
      'priority' => 100,
      'authentication' => [
        {
          'auth_type' => 'AH',
          'auth_pass' => password
        }
      ],
      'virtual_ipaddress' => [
        "#{node['environment_v2']['set']['dns']['vip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
      ]
    }
  ]
})
