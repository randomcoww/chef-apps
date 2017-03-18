execute "pkg_update" do
  command node['unbound']['pkg_update_command']
  action :run
end

package node['unbound']['pkg_names'] do
  action :upgrade
  notifies :restart, "service[unbound]", :delayed
end

# nsd_resource_rndc_key_config 'main_rndc-key' do
#   rndc_keys_data_bag node['unbound']['main']['rndc_keys_data_bag']
#   rndc_keys_data_bag_item node['unbound']['main']['rndc_keys_data_bag_item']
#   rndc_key_names node['unbound']['main']['rndc_key_names']
#
#   path '/etc/unbound/unbound.conf.d/rndc-key.conf'
#   notifies :restart, "service[unbound]", :delayed
# end

remote_file '/etc/unbound/root-hints.conf' do
  source 'https://www.internic.net/domain/named.cache'
  action :create
  notifies :restart, "service[unbound]", :delayed
end

unbound_config 'main' do
  config node['unbound']['main']['config']
  action :create
  notifies :restart, "service[unbound]", :delayed
end

include_recipe "unbound::service"
