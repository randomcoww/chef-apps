package 'kea-dhcp-ddns-server' do
  action :install
  notifies :stop, "service[kea-dhcp-ddns-server]", :immediately
end

kea_dhcp_ddns_config 'kea-ddns' do
  config node['kea']['ddns']['config']
  action :create
  notifies :restart, "service[kea-dhcp-ddns-server]", :delayed
end

include_recipe "kea::dhcp-ddns_service"
