execute "pkg_update" do
  command node['kea']['pkg_update_command']
  action :run
end

package node['kea']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[kea-dhcp4-server]", :immediately
end

kea_dhcp4_config 'kea-mysql' do
  config node['kea']['mysql']['config']
  action :create
  notifies :restart, "service[kea-dhcp4-server]", :delayed
end

include_recipe "kea::dhcp4_service"
