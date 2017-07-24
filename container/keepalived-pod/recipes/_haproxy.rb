dbag = Dbag::Keystore.new('deploy_config', 'keepalived')

node.default['kubelet']['keepalived']['config'] = KeepalivedHelper::ConfigGenerator.generate_from_hash({
  'vrrp_sync_group VG_haproxy' => [
    {
      'group' => [
        'VI_haproxy'
      ]
    }
  ],
  'vrrp_instance VI_haproxy' => [
    {
      'state' => 'BACKUP',
      'virtual_router_id' => 21,
      'interface' => node['environment_v2']['current_host']['if_lan'],
      'priority' => 100,
      'authentication' => [
        {
          'auth_type' => 'AH',
          'auth_pass' => dbag.get_or_create('VI_haproxy', SecureRandom.base64(6))
        }
      ],
      'virtual_ipaddress' => [
        "#{node['environment_v2']['set']['haproxy']['vip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
      ]
    }
  ]
})
