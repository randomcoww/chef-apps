execute "pkg_update" do
  command node['nsd']['pkg_update_command']
  action :run
end

## service starts automatically with default configs on install
## this conflicts with unbound running on default port
## stop until configs are written to run on another port
package node['nsd']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[nsd]", :immediately
end

nsd_resource_rndc_key_config 'rndc-key' do
  rndc_keys_data_bag node['nsd']['main']['rndc_keys_data_bag']
  rndc_keys_data_bag_item node['nsd']['main']['rndc_keys_data_bag_item']
  rndc_key_names node['nsd']['main']['rndc_key_names']

  path '/etc/nsd/nsd.conf.d/rndc-key.conf'
  notifies :restart, "service[nsd]", :delayed
end

static_hosts = {}
node['environment_v2']['host'].each do |hostname, d|
  if !d['ip_lan'].nil?
    static_hosts[hostname] = d['ip_lan']
  end
end

node['environment_v2']['vip'].each do |hostname, ip|
  if !ip.nil?
    static_hosts[hostname] = ip
  end
end


nsd_zonefile 'static.lan' do
  domain 'static.lan'
  name_server 'ns1.static.lan'
  email_addr 'root.static.lan'
  hosts static_hosts
  notifies :reload, "service[nsd]", :delayed
end

nsd_config 'nsd' do
  config node['nsd']['main']['config'].merge({
    'zone' => [
      {
        'name' => 'static.lan',
        'zonefile' => ::File.join(Chef::Config[:file_cache_path], 'nsd', 'static.lan')
      }
    ]
  })
  action :create
  notifies :restart, "service[nsd]", :delayed
end

include_recipe "nsd::service"
