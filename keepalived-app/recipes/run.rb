execute "pkg_update" do
  command node['keepalived']['pkg_update_command']
  action :run
end

package node['keepalived']['pkg_names'] do
  action :upgrade
end

node['keepalived']['instances'].each do |name, v|
  keepalived name do
    deploy_path ::File.join(Chef::Config[:file_cache_path], 'keepalived', name)
    git_repo v['git_repo']
    git_branch v['git_branch']

    keystore_data_bag 'deploy_config'
    keystore_data_bag_item 'keystore'
    template_variables v['template_variables']
    action :deploy
  end
end
