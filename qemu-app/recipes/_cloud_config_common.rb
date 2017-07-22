node.default['qemu']['current_config']['cloud_config'] = {
  "write_files" => [],
  "password" => "password",
  "chpasswd" => {
    "expire" => false
  },
  "ssh_pwauth" => false,
  "package_update" => false,
  "package_upgrade" => false,
  "package_reboot_if_required" => false,
  "cc_resolv_conf" => false,
  "manage_etc_hosts" => true,
  "fqdn" => "#{node['qemu']['current_config']['hostname']}.lan",
  "runcmd" => node['qemu']['current_config']['runcmd'] + [
    [
      "chef-client", "-o",
      node['qemu']['current_config']['chef_recipes'].join(',')
    ],
    "systemctl enable chef-client.timer",
    "systemctl start chef-client.timer"
  ]
}
