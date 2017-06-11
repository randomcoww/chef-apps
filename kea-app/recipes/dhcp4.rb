include_recipe "kea-app::_mysql_backend"

package 'kea-dhcp4-server' do
  action :install
  notifies :stop, "service[kea-dhcp4-server]", :immediately
end

kea_dhcp4_config 'kea-mysql' do
  config node['kea']['dhcp4_mysql']['config']
  action :create
  notifies :restart, "service[kea-dhcp4-server]", :delayed
end

include_recipe "kea::dhcp4_service_mysql"
