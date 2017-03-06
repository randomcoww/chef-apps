execute "pkg_update" do
  command node['nsd']['pkg_update_command']
  action :run
end

include_recipe "nsd::service"

package node['nsd']['pkg_names'] do
  action :upgrade
  notifies :restart, "service[nsd]", :delayed
end

nsd_resource_rndc_key_config 'rndc-key' do
  rndc_keys_data_bag node['nsd']['rndc_keys']['rndc_keys_data_bag']
  rndc_keys_data_bag_item node['nsd']['rndc_keys']['rndc_keys_data_bag_item']
  rndc_key_names node['nsd']['rndc_keys']['rndc_key_names']

  path '/etc/nsd/nsd.conf.d/rndc-key.conf'
  notifies :restart, "service[nsd]", :delayed
end

nsd_git_zones 'nsd-zones' do
  git_repo node['nsd']['git_zones']['git_repo']
  git_branch node['nsd']['git_zones']['git_branch']
  release_path node['nsd']['git_zones']['release_path']
  zone_options node['nsd']['git_zones']['zone_options']

  path '/etc/nsd/nsd.conf.d/zones.conf'
  notifies :reload, "service[nsd]", :delayed
end

nsd_config 'nsd' do
  config node['nsd']['config']
  action :create
  notifies :restart, "service[nsd]", :delayed
end
