dbag = Dbag::Keystore.new(
  node['keepalived']['auth_data_bag'],
  node['keepalived']['auth_data_bag_item']
)
password = dbag.get_or_create('VG_lb', SecureRandom.base64(6))

execute "pkg_update" do
  command node['keepalived']['pkg_update_command']
  action :run
end

include_recipe 'keepalived::install'
include_recipe 'keepalived::configure'

keepalived_vrrp_sync_group 'VG_lb' do
  group [ "VI_lb" ]
end

keepalived_vrrp_instance 'VI_lb' do
  nopreempt true
  interface node['keepalived']['lb']['lan_if']
  virtual_router_id 22
  # use_vmac 'vrrp22'
  authentication auth_type: 'AH', auth_pass: password
  virtual_ipaddress [ "#{node['environment_v2']['lb_lan_vip']}/#{node['environment_v2']['lan_subnet'].split('/').last}" ]
end

include_recipe 'keepalived::service'
