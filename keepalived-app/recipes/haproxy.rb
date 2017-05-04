dbag = Dbag::Keystore.new(
  node['keepalived']['auth_data_bag'],
  node['keepalived']['auth_data_bag_item']
)
password = dbag.get_or_create('VI_haproxy', SecureRandom.base64(6))

include_recipe 'keepalived::install'
include_recipe 'keepalived::configure'

keepalived_vrrp_sync_group 'VG_haproxy' do
  group [ "VI_haproxy" ]
end

keepalived_vrrp_instance 'VI_haproxy' do
  nopreempt true
  interface node['keepalived']['haproxy']['lan_if']
  virtual_router_id 31
  authentication auth_type: 'AH', auth_pass: password
  virtual_ipaddress [ "#{node['environment_v2']['vip']['haproxy_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}" ]
end

include_recipe 'keepalived::service'
