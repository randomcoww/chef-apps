node.default['keepalived']['pkg_update_command'] = "apt-get update -qqy"
node.default['keepalived']['pkg_names'] = ['git', 'keepalived']
node.default['keepalived']['instances']['primary'] = {
  'git_repo' => 'https://github.com/randomcoww/keepalived-config.git',
  'git_branch' => 'primary',
  'template_variables' => {
    'if_lan' => 'brlan',
    'state' => 'MASTER',
    'id_lan' => 55,
    'priority' => 200,
    'vip_lan' => "192.168.63.89"
  }
}
