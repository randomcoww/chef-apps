dbag = Dbag::Keystore.new(
  node['keepalived']['auth_data_bag'],
  node['keepalived']['auth_data_bag_item']
)
lan_password = dbag.get_or_create('VI_lan_gluster', SecureRandom.base64(6))
store_password = dbag.get_or_create('VI_store_gluster', SecureRandom.base64(6))

include_recipe 'keepalived::install'
include_recipe 'keepalived::configure'

keepalived_vrrp_sync_group 'VG_gluster' do
  group [ "VI_lan_gluster", "VI_store_gluster" ]
end

keepalived_vrrp_instance 'VI_lan_gluster' do
  nopreempt true
  interface node['keepalived']['gluster']['lan_if']
  virtual_router_id 23
  authentication auth_type: 'AH', auth_pass: lan_password
  virtual_ipaddress [ "#{node['environment_v2']['vip']['gluster_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}" ]
end

keepalived_vrrp_instance 'VI_store_gluster' do
  nopreempt true
  interface node['keepalived']['gluster']['store_if']
  virtual_router_id 24
  authentication auth_type: 'AH', auth_pass: store_password
  virtual_ipaddress [ "#{node['environment_v2']['vip']['gluster_store']}/#{node['environment_v2']['subnet']['store'].split('/').last}" ]
end

include_recipe 'keepalived::service'
