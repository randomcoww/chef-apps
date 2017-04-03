node.default['nftables']['filter']['git_repo'] = 'https://github.com/randomcoww/nftables-config.git'
node.default['nftables']['filter']['git_branch'] = 'filter'
node.default['nftables']['filter']['deploy_path'] = ::File.join(Chef::Config[:file_cache_path], 'nftables')
node.default['nftables']['filter']['template_variables'] = {
  'accept_interface' => 'tun*',
  'accept_groups' => ['root', 'nogroup'],
  'accept_ip_ranges' => ['192.168.0.0/16']
}
