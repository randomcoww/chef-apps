node.default['nftables']['pkg_update_command'] = "apt-get update -qqy"
node.default['nftables']['pkg_names'] = ['git', 'nftables']

node.default['nftables']['git_repo'] = 'https://github.com/randomcoww/nftables-config.git'
node.default['nftables']['git_branch'] = 'master'
node.default['nftables']['deploy_path'] = ::File.join(Chef::Config[:file_cache_path], 'nftables')
node.default['nftables']['template_variables'] = {
  'lan_if' => node['environment']['lan_if'],
  'vpn_if' => node['environment']['vpn_if'],
  'wan_if' => node['environment']['wan_if']
}
