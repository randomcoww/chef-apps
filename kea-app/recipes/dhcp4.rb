execute "pkg_update" do
  command node['kea']['pkg_update_command']
  action :run
end

package node['kea']['pkg_names'] do
  action :upgrade
  notifies :restart, "service[kea-dhcp4-server]", :delayed
end

kea_dhcp4_config 'kea-dhcp4' do
  config node['kea']['dhcp4_config']
  action :create
  notifies :restart, "service[kea-dhcp4-server]", :delayed
end

include_recipe "kea::dhcp4_service"
