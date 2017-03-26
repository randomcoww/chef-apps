execute "pkg_update" do
  command node['nftables']['pkg_update_command']
  action :run
end

package node['nftables']['pkg_names'] do
  action :upgrade
end

nftables_git_rules 'filter' do
  deploy_path node['nftables']['filter']['deploy_path']
  git_repo node['nftables']['filter']['git_repo']
  git_branch node['nftables']['filter']['git_branch']
  template_variables node['nftables']['filter']['template_variables']
  action :deploy
end
