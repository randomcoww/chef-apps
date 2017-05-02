dbag = Dbag::Keystore.new(
  node['keepalived']['auth_data_bag'],
  node['keepalived']['auth_data_bag_item']
)
password = dbag.get_or_create('VI_mysql', SecureRandom.base64(6))

execute "pkg_update" do
  command node['keepalived']['pkg_update_command']
  action :run
end

include_recipe 'keepalived::install'
include_recipe 'keepalived::configure'

keepalived_vrrp_sync_group 'VG_mysql' do
  group [ "VI_mysql" ]
end

keepalived_vrrp_instance 'VI_mysql' do
  nopreempt true
  interface node['keepalived']['mysql']['lan_if']
  virtual_router_id 41
  authentication auth_type: 'AH', auth_pass: password
  virtual_ipaddress [ "#{node['environment_v2']['vip']['mysql_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}" ]
end

include_recipe 'keepalived::service'
