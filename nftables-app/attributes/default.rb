node.default['nftables']['pkg_update_command'] = "apt-get update -qqy"
node.default['nftables']['pkg_names'] = ['git', 'nftables']

node.default['nftables']['gateway']['git_repo'] = 'https://github.com/randomcoww/nftables-config.git'
node.default['nftables']['gateway']['git_branch'] = 'master'
node.default['nftables']['gateway']['deploy_path'] = ::File.join(Chef::Config[:file_cache_path], 'nftables')
node.default['nftables']['gateway']['template_variables'] = {
  'lan_if' => node['environment']['lan_if'],
  'vpn_if' => node['environment']['vpn_if'],
  'wan_if' => node['environment']['wan_if']
}

node.default['nftables']['filter']['git_repo'] = 'https://github.com/randomcoww/nftables-config.git'
node.default['nftables']['filter']['git_branch'] = 'filter'
node.default['nftables']['filter']['deploy_path'] = ::File.join(Chef::Config[:file_cache_path], 'nftables')
node.default['nftables']['filter']['template_variables'] = {
  'accept_interface' => 'tun*',
  'accept_groups' => ['root', 'nogroup'],
  'accept_ip_ranges' => ['192.168.0.0/16']
}
