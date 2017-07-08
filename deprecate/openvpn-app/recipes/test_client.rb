package node['openvpn']['test_client']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[openvpn@client]", :immediately
end

openvpn_client_config 'openvpn_client' do
  config node['openvpn']['test_client']['config']
  action :create
  notifies :restart, "service[openvpn@client]", :delayed
end

openvpn_ca 'ca' do
  data_bag 'deploy_config'
  data_bag_item 'openvpn_ssl'
  root_subject ([
    ['CN', 'ovpn-ca']
  ])
  action :create
end

openvpn_client_cert 'client' do
  data_bag 'deploy_config'
  data_bag_item 'openvpn_ssl'
  root_subject ([
    ['CN', 'ovpn-ca']
  ])
  subject ([
    ['CN', 'ovpn-ca']
  ])
  action :create_if_missing
end

include_recipe "openvpn::client_service"
