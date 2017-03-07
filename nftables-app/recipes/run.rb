execute "pkg_update" do
  command node['nftables']['pkg_update_command']
  action :run
end

package node['nftables']['pkg_names'] do
  action :upgrade
end

nftables_rules 'nftables' do
  deploy_path node['nftables']['deploy_path']
  git_repo node['nftables']['git_repo']
  git_branch node['nftables']['git_branch']
  template_variables node['nftables']['template_variables']
  action :deploy
end
