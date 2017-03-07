execute "pkg_update" do
  command node['nsd']['pkg_update_command']
  action :run
end

package node['nsd']['pkg_names'] do
  action :upgrade
  notifies :restart, "service[nsd]", :delayed
end

nsd_resource_rndc_key_config 'main_rndc-key' do
  rndc_keys_data_bag node['nsd']['main']['rndc_keys_data_bag']
  rndc_keys_data_bag_item node['nsd']['main']['rndc_keys_data_bag_item']
  rndc_key_names node['nsd']['main']['rndc_key_names']

  path '/etc/nsd/nsd.conf.d/rndc-key.conf'
  notifies :restart, "service[nsd]", :delayed
end

nsd_git_zones 'main_nsd-zones' do
  git_repo node['nsd']['main']['git_repo']
  git_branch node['nsd']['main']['git_branch']
  release_path node['nsd']['main']['release_path']
  zone_options node['nsd']['main']['zone_options']

  path '/etc/nsd/nsd.conf.d/zones.conf'
  notifies :reload, "service[nsd]", :delayed
end

nsd_config 'nsd' do
  config node['nsd']['main']['config']
  action :create
  notifies :restart, "service[nsd]", :delayed
end

include_recipe "nsd::service"
