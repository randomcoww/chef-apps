node.default['qemu']['current_config']['cloud_config'] = {
  "write_files" => [],
  "users" => [
    {
      "name" => "debian",
      "lock_passwd" => false,
      "ssh-authorized-keys" => node['environment_v2']['ssh_authorized_keys']['default']
    }
  ],
  "ssh_pwauth" => false,
  "package_update" => false,
  "package_upgrade" => false,
  "package_reboot_if_required" => false,
  "cc_resolv_conf" => false,
  "manage_etc_hosts" => true,
  "fqdn" => "#{node['qemu']['current_config']['hostname']}.lan",
  "packages" => node['qemu']['current_config']['packages'],
  "bootcmd" => [
    [ "cloud-init-per", "once", "systemd_load",
      "systemctl", "daemon-reload" ],
    [ "cloud-init-per", "once", "networkd_load",
      "systemctl", "restart", "systemd-networkd" ]
  ],
  "runcmd" => node['qemu']['current_config']['runcmd'] + [
    [
      "chef-client", "-o",
      node['qemu']['current_config']['chef_recipes'].join(',')
    ],
    "systemctl enable chef-client.timer",
    "systemctl start chef-client.timer"
  ]
}
