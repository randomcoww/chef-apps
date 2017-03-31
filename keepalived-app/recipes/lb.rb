dbag = Dbag::Keystore.new(
  node['keepalived']['auth_data_bag'],
  node['keepalived']['auth_data_bag_item']
)
password = dbag.get_or_create('VG_lb', SecureRandom.base64(6))

include_recipe 'keepalived::install'
include_recipe 'keepalived::configure'

keepalived_vrrp_sync_group 'VG_lb' do
  group [ "VI_lb" ]
end

keepalived_vrrp_instance 'VI_lb' do
  nopreempt true
  interface node['environment']['lb_if']
  virtual_router_id node['environment']['lb_ha_id']
  authentication auth_type: 'AH', auth_pass: password
  virtual_ipaddress [ node['environment']['lb_vip'] ]
end

include_recipe 'keepalived::service'
