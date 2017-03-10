dbag = Dbag::Keystore.new(
  node['keepalived']['dns']['auth_data_bag'],
  node['keepalived']['dns']['auth_data_bag_item']
)
password = dbag.get_or_create('dns1', SecureRandom.base64(6))

include_recipe 'keepalived::install'
include_recipe 'keepalived::configure'

keepalived_vrrp_sync_group 'dns1' do
  group [ "VI1" ]
end

keepalived_vrrp_instance 'VI1' do
  state node['environment']['lan_vrrp_state']
  interface node['environment']['dns_if']
  virtual_router_id node['environment']['lan_vrrp_id']
  priority node['environment']['lan_vrrp_priority']
  authentication auth_type: 'PASS', auth_pass: password
  virtual_ipaddress [ node['environment']['dns_vip'] ]
end

include_recipe 'keepalived::service'
