execute "pkg_update" do
  command node['openvpn']['pkg_update_command']
  action :run
end

package node['openvpn']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[openvpn@server]", :immediately
end

openvpn_server_config 'openvpn_server' do
  config node['openvpn']['server']['config']
  action :create
  notifies :restart, "service[openvpn@server]", :delayed
end

openvpn_server_credentials 'ca.crt' do
  content ca_crt
  action :create
  notifies :restart, "service[openvpn@server]", :delayed
end

openvpn_server_credentials 'dh' do
  content dh
  action :create
  notifies :restart, "service[openvpn@server]", :delayed
end

openvpn_server_credentials 'server.crt' do
  content server_crt
  action :create
  notifies :restart, "service[openvpn@server]", :delayed
end

openvpn_server_credentials 'server.csr' do
  content server.csr
  action :create
  notifies :restart, "service[openvpn@server]", :delayed
end

include_recipe "openvpn::server_service"
