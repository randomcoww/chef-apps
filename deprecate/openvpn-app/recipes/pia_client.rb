package node['openvpn']['pia_client']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[openvpn@client]", :immediately
end

openvpn_client_config 'pia_client' do
  config node['openvpn']['pia_client']['config']
  action :create
  notifies :restart, "service[openvpn@client]", :delayed
end

openvpn_credentials_config 'client_auth' do
  data_bag node['openvpn']['pia_client']['auth-user-pass']['data_bag']
  data_bag_item node['openvpn']['pia_client']['auth-user-pass']['data_bag_item']
  key node['openvpn']['pia_client']['auth-user-pass']['key']
  action :create
  notifies :restart, "service[openvpn@client]", :delayed
end

openvpn_credentials_config 'ca.crt' do
  data_bag node['openvpn']['pia_client']['ca']['data_bag']
  data_bag_item node['openvpn']['pia_client']['ca']['data_bag_item']
  key node['openvpn']['pia_client']['ca']['key']
  action :create
  notifies :restart, "service[openvpn@client]", :delayed
end

include_recipe "openvpn::client_service"
