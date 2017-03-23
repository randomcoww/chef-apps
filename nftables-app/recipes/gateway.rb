execute "pkg_update" do
  command node['nftables']['pkg_update_command']
  action :run
end

package node['nftables']['pkg_names'] do
  action :upgrade
end

nftables_git_rules 'gateway' do
  deploy_path node['nftables']['gateway']['deploy_path']
  git_repo node['nftables']['gateway']['git_repo']
  git_branch node['nftables']['gateway']['git_branch']
  template_variables node['nftables']['gateway']['template_variables']
  action :deploy
end
