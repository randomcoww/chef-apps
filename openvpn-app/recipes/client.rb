execute "pkg_update" do
  command node['openvpn']['pkg_update_command']
  action :run
end

package node['openvpn']['pkg_names'] do
  action :upgrade
  notifies :restart, "service[openvpn@client]", :delayed
end

openvpn_client_config 'openvpn_client' do
  config node['openvpn']['client']['config']
  action :create
  notifies :restart, "service[openvpn@client]", :delayed
end

openvpn_client_credentials 'client_auth' do
  data_bag node['openvpn']['client']['auth-user-pass']['data_bag']
  data_bag_item node['openvpn']['client']['auth-user-pass']['data_bag_item']
  key node['openvpn']['client']['auth-user-pass']['key']
  action :create
  notifies :restart, "service[openvpn@client]", :delayed
end

openvpn_client_credentials 'ca.crt' do
  data_bag node['openvpn']['client']['ca']['data_bag']
  data_bag_item node['openvpn']['client']['ca']['data_bag_item']
  key node['openvpn']['client']['ca']['key']
  action :create
  notifies :restart, "service[openvpn@client]", :delayed
end

include_recipe "openvpn::client_service"
