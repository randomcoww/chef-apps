execute "pkg_update" do
  command node['unbound']['pkg_update_command']
  action :run
end

include_recipe "unbound::service"

package node['unbound']['pkg_names'] do
  action :upgrade
  notifies :restart, "service[unbound]", :delayed
end

nsd_resource_rndc_key_config 'rndc-key' do
  rndc_keys_data_bag node['unbound']['rndc_keys']['rndc_keys_data_bag']
  rndc_keys_data_bag_item node['unbound']['rndc_keys']['rndc_keys_data_bag_item']
  rndc_key_names node['unbound']['rndc_keys']['rndc_key_names']

  path '/etc/unbound/unbound.conf.d/rndc-key.conf'
  notifies :restart, "service[unbound]", :delayed
end

remote_file '/etc/unbound/root-hints.conf' do
  source 'https://www.internic.net/domain/named.cache'
  action :create
  notifies :restart, "service[unbound]", :delayed
end

unbound_config 'unbound' do
  config node['unbound']['config']
  action :create
  notifies :restart, "service[unbound]", :delayed
end
