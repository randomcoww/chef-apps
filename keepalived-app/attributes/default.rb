node.default['keepalived']['pkg_update_command'] = "apt-get update -qqy"
node.default['keepalived']['pkg_names'] = ['git', 'keepalived']
node.default['keepalived']['instances']['primary'] = {
  'git_repo' => 'https://github.com/randomcoww/keepalived-config.git',
  'git_branch' => 'master',
  'template_variables' => {
    'lan_if' => node['environment']['lan_if'],
    'state' => node['environment']['lan_vrrp_state'],
    'lan_id' => node['environment']['lan_vrrp_id'],
    'priority' => node['environment']['lan_vrrp_priority'],
    'lan_vip' => node['environment']['lan_vip_gateway']
  }
}
