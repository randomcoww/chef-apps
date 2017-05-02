dbag = Dbag::Keystore.new(
  node['keepalived']['auth_data_bag'],
  node['keepalived']['auth_data_bag_item']
)
password = dbag.get_or_create('VI_gateway', SecureRandom.base64(6))

execute "pkg_update" do
  command node['keepalived']['pkg_update_command']
  action :run
end

include_recipe 'keepalived::install'
include_recipe 'keepalived::configure'

keepalived_vrrp_sync_group 'VG_gateway' do
  group [ "VI_gateway" ]
end

keepalived_vrrp_instance 'VI_gateway' do
  nopreempt true
  interface node['keepalived']['gateway']['lan_if']
  virtual_router_id 20
  # use_vmac 'vrrp20'
  authentication auth_type: 'AH', auth_pass: password
  virtual_ipaddress [ "#{node['environment_v2']['vip']['gateway_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}" ]
  notify_master %Q{"/sbin/ip link set #{node['keepalived']['gateway']['wan_if']} up"}
  notify_backup %Q{"/sbin/ip link set #{node['keepalived']['gateway']['wan_if']} down"}
  notify_fault %Q{"/sbin/ip link set #{node['keepalived']['gateway']['wan_if']} down"}
end

include_recipe 'keepalived::service'
