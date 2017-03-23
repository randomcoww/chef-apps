execute "pkg_update" do
  command node['unbound']['pkg_update_command']
  action :run
end

package node['unbound']['pkg_names'] do
  action :upgrade
  notifies :stop, "service[unbound]", :immediately
end

remote_file '/etc/unbound/root-hints.conf' do
  source 'https://www.internic.net/domain/named.cache'
  action :create
  notifies :reload, "service[unbound]", :delayed
end

unbound_config 'main' do
  config node['unbound']['main']['config']
  action :create
  notifies :reload, "service[unbound]", :delayed
end

include_recipe "unbound::service"
