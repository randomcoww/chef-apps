## service starts automatically with default configs on install
## this conflicts with unbound running on default port
## stop until configs are written to run on another port
package node['knot']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[knot]", :immediately
end


directory node['knot']['main']['storage'] do
  recursive true
  owner node['knot']['main']['user']
  group node['knot']['main']['group']
end

## timers and journal directory owned by knot is needed under storage
['timers', 'journal'].each do |d|
  directory ::File.join(node['knot']['main']['storage'], d) do
    recursive true
    owner node['knot']['main']['user']
    group node['knot']['main']['group']
  end
end


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

knot_zonefile 'st.lan' do
  domain 'st.lan'
  name_server 'ns1.st.lan'
  email_addr 'root.st.lan'
  hosts static_hosts
  notifies :reload, "service[knot]", :delayed
end

knot_zonefile 'dy.lan' do
  domain 'dy.lan'
  name_server 'ns1.dy.lan'
  email_addr 'root.dy.lan'
  hosts ({})
  action :create_if_missing
  notifies :reload, "service[knot]", :delayed
end


## main config

knot_config 'knot' do
  config node['knot']['main']['config']
  action :create
  notifies :restart, "service[knot]", :delayed
end

include_recipe "knot::service"
