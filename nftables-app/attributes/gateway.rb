node.default['nftables']['gateway']['git_repo'] = 'https://github.com/randomcoww/nftables-config.git'
node.default['nftables']['gateway']['git_branch'] = 'master'
node.default['nftables']['gateway']['deploy_path'] = ::File.join(Chef::Config[:file_cache_path], 'nftables')
node.default['nftables']['gateway']['template_variables'] = {
  'lan_if' => 'eth0',
  'vpn_if' => 'eth1',
  'wan_if' => 'eth2'
}
