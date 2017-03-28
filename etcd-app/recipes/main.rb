dbag = Dbag::Keystore.new(
  node['etcd']['main']['data_bag'],
  node['etcd']['main']['data_bag_item']
)
discovery = dbag.get('discovery')

if discovery.nil?
  discovery = Chef::HTTP.new("https://discovery.etcd.io").get("new?size=#{node['etcd']['main']['cluster_size']}")
  dbag.put('discovery', discovery)
end

etcd_installation 'main' do
  version node['etcd']['main']['version']
  action :create
end

etcd_service "#{node['hostname']}-#{node['ipaddress']}" do
  discovery discovery
  data_dir '/var/lib/etcd'
  service_manager 'systemd'

  initial_advertise_peer_urls "http://#{node['ipaddress']}:2380"
  listen_peer_urls "http://#{node['ipaddress']}:2380"

  listen_client_urls ["http://#{node['ipaddress']}:2379", "http://127.0.0.1:2379"].join(',')
  advertise_client_urls "http://#{node['ipaddress']}:2379"
  action :start
end
