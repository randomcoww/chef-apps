dbag = Dbag::Keystore.new(
  node['keepalived']['dns']['auth_data_bag'],
  node['keepalived']['dns']['auth_data_bag_item']
)
password = dbag.get_or_create('dns1', SecureRandom.base64(6))

include_recipe 'keepalived::install'
include_recipe 'keepalived::configure'

keepalived_vrrp_sync_group 'VG_dns' do
  group [ "VI_dns" ]
end

keepalived_vrrp_instance 'VI_dns' do
  state 'BACKUP'
  use_vmac ''
  interface node['environment']['dns_if']
  virtual_router_id node['environment']['dns_ha_id']
  priority node['environment']['dns_ha_priority']
  authentication auth_type: 'AH', auth_pass: password
  virtual_ipaddress [ node['environment']['dns_vip'] ]
end

include_recipe 'keepalived::service'
