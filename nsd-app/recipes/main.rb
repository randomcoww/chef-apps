## service starts automatically with default configs on install
## this conflicts with unbound running on default port
## stop until configs are written to run on another port
package node['nsd']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[nsd]", :immediately
end

chef_gem 'mysql2' do
  action :install
  compile_time false
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

node['environment_v2']['vip'].each do |hostname, ip|
  if !ip.nil?
    static_hosts[hostname] = ip
  end
end

nsd_zonefile 'st.lan' do
  domain 'st.lan'
  name_server 'ns1.st.lan'
  email_addr 'root.st.lan'
  hosts static_hosts
  notifies :reload, "service[nsd]", :delayed
end

## grab dynamic hosts from kea leases table

nsd_kea_zonefile 'dy.lan' do
  domain 'dy.lan'
  name_server 'ns1.dy.lan'
  email_addr 'root.dy.lan'
  username node['mysql_credentials']['kea']['username']
  database node['mysql_credentials']['kea']['database']
  host node['environment_v2']['vip']['mysql_lan']
  password node['mysql_credentials']['kea']['password']
  notifies :reload, "service[nsd]", :delayed
end

## main config

nsd_config 'nsd' do
  config node['nsd']['main']['config'].merge({
    'zone' => [
      {
        'name' => 'st.lan',
        'zonefile' => ::File.join(Chef::Config[:file_cache_path], 'nsd', 'st.lan')
      },
      {
        'name' => 'dy.lan',
        'zonefile' => ::File.join(Chef::Config[:file_cache_path], 'nsd', 'dy.lan')
      }
    ]
  })
  action :create
  notifies :restart, "service[nsd]", :delayed
end

include_recipe "nsd::service"
