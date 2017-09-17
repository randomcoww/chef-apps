dbag = Dbag::Keystore.new(
  node['keepalived']['auth_data_bag'],
  node['keepalived']['auth_data_bag_item']
)
password = dbag.get_or_create('VI_dns', SecureRandom.base64(6))

include_recipe 'keepalived::install'
include_recipe 'keepalived::configure'

keepalived_vrrp_sync_group 'VG_dns' do
  group [ "VI_dns" ]
end

keepalived_vrrp_instance 'VI_dns' do
  # nopreempt true
  # state 'MASTER'
  interface node['environment_v2']['current_host']['if_lan']
  virtual_router_id 22
  # use_vmac 'vrrp22'
  authentication auth_type: 'AH', auth_pass: password
  virtual_ipaddress [ "#{node['environment_v2']['set']['dns']['vip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}" ]
end

include_recipe 'keepalived-app::systemd_service'