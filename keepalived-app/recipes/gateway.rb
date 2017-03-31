dbag = Dbag::Keystore.new(
  node['keepalived']['auth_data_bag'],
  node['keepalived']['auth_data_bag_item']
)
password = dbag.get_or_create('VG_gateway', SecureRandom.base64(6))

include_recipe 'keepalived::install'
include_recipe 'keepalived::configure'

keepalived_vrrp_sync_group 'VG_gateway' do
  group [ "VI_gateway" ]
end

keepalived_vrrp_instance 'VI_gateway' do
  nopreempt true
  interface node['environment']['lan_if']
  virtual_router_id node['environment']['lan_vrrp_id']
  authentication auth_type: 'AH', auth_pass: password
  virtual_ipaddress [ node['environment']['lan_vip_gateway'] ]
  notify_master %Q{"/sbin/ip link set #{node['environment']['wan_if']} up"}
  notify_backup %Q{"/sbin/ip link set #{node['environment']['wan_if']} down"}
  notify_fault %Q{"/sbin/ip link set #{node['environment']['wan_if']} down"}
end

include_recipe 'keepalived::service'
