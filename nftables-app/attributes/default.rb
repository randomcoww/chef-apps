node.default['nftables']['pkg_update_command'] = "apt-get update -qqy"
node.default['nftables']['pkg_names'] = ['git', 'nftables']
node.default['nftables']['instances']['primary'] = {
  'git_repo' => 'https://github.com/randomcoww/nftables-config.git',
  'git_branch' => 'master',
  'template_variables' => {
    'lan_if' => node['environment']['lan_if'],
    'vpn_if' => node['environment']['vpn_if'],
    'wan_if' => node['environment']['wan_if']
  }
}
