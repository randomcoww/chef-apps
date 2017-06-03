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

## grab static hosts from environment_v2

static_hosts = {}

node['environment_v2']['host'].each do |hostname, d|
  if !d['ip_lan'].nil?
    static_hosts[hostname] = d['ip_lan']
  end
end

node['environment_v2']['set'].each do |set, d|
  if !d['vip_lan'].nil?
    static_hosts[set] = d['vip_lan']
  end
end

nsd_zonefile 'st.lan' do
  domain 'st.lan'
  name_server 'ns1.st.lan'
  email_addr 'root.st.lan'
  hosts static_hosts
  notifies :reload, "service[nsd]", :delayed
end

## main config

nsd_config 'nsd' do
  config node['nsd']['main']['config'].merge({
    'zone' => [
      {
        'name' => 'st.lan',
        'zonefile' => ::File.join(Chef::Config[:file_cache_path], 'nsd', 'st.lan')
      }
    ]
  })
  action :create
  notifies :restart, "service[nsd]", :delayed
end

include_recipe "nsd::service"
