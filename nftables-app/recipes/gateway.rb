package node['nftables']['pkg_names'] do
  action :upgrade
end

nftables_git_rules 'gateway' do
  deploy_path node['nftables']['gateway']['deploy_path']
  git_repo node['nftables']['gateway']['git_repo']
  git_branch node['nftables']['gateway']['git_branch']
  template_variables ({
    current_host: node['environment_v2']['current_host'],
    sets: node['environment_v2']['set'],
    hosts: node['environment_v2']['host']
  })
  action :deploy
end
