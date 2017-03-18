dbag = Dbag::Keystore.new(
  node['keepalived']['gateway']['auth_data_bag'],
  node['keepalived']['gateway']['auth_data_bag_item']
)
password = dbag.get_or_create('VG_gateway', SecureRandom.base64(6))

include_recipe 'keepalived::install'
include_recipe 'keepalived::configure'

Chef::Log.info("NODE IP #{node['ipaddress']}")

keepalived_vrrp_sync_group 'VG_gateway' do
  group [ "VI_gateway" ]
end

keepalived_vrrp_instance 'VI_gateway' do
  state 'BACKUP'
  use_vmac 'vrrp20'
  nopreempt true
  interface node['environment']['lan_if']
  virtual_router_id node['environment']['lan_vrrp_id']
  priority 100
  authentication auth_type: 'AH', auth_pass: password
  virtual_ipaddress [ node['environment']['lan_vip_gateway'] ]
end

include_recipe 'keepalived::service'