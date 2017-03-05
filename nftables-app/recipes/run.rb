execute "pkg_update" do
  command node['nftables']['pkg_update_command']
  action :run
end

package node['nftables']['pkg_names'] do
  action :upgrade
end

node['nftables']['instances'].each do |name, v|
  nftables name do
    deploy_path ::File.join(Chef::Config[:file_cache_path], 'nftables', name)
    git_repo v['git_repo']
    git_branch v['git_branch']

    keystore_data_bag 'deploy_config'
    keystore_data_bag_item 'keystore'
    template_variables v['template_variables']
    action :deploy
  end
end
