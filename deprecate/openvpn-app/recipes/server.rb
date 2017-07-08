package node['openvpn']['server']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[openvpn@server]", :immediately
end

openvpn_server_config 'openvpn_server' do
  config node['openvpn']['server']['config']
  action :create
  notifies :restart, "service[openvpn@server]", :delayed
end

openvpn_ca 'ca' do
  data_bag 'deploy_config'
  data_bag_item 'openvpn_ssl'
  root_subject ([
    ['CN', 'ovpn-ca']
  ])
  action :create
end

openvpn_dh 'dh' do
  action :create_if_missing
end

openvpn_server_cert 'server' do
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

include_recipe "openvpn::server_service"
