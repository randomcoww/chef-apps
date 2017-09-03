# node.default['qemu']['current_config']['hostname'] = 'host'
node.default['qemu']['current_config']['cloud_config_path'] = "/data/cloud-init/#{node['qemu']['current_config']['hostname']}"

node.default['qemu']['current_config']['chef_interval'] = '60min'
node.default['qemu']['current_config']['chef_recipes'] = [
  "recipe[system_update::debian]"
]

node.default['qemu']['current_config']['memory'] = 512
node.default['qemu']['current_config']['vcpu'] = 1

node.default['qemu']['current_config']['runcmd'] = [
  "systemctl disable mongodb",
  "systemctl start unifi",
  "systemctl enable unifi"
]

node.default['qemu']['current_config']['cloud_config'] = {
  "write_files" => [],
  "users" => [
    {
      "name" => "debian",
      "lock_passwd" => false,
      "ssh-authorized-keys" => node['environment_v2']['ssh_authorized_keys']['default']
    }
  ],
  "apt" => {
    "preserve_sources_list" => true,
    "sources" => {
      "unifi" => {
        "keyid" => "C0A52C50",
        "keyserver" => "keyserver.ubuntu.com",
        "source" => "deb http://www.ubnt.com/downloads/unifi/debian unifi5 ubiquiti"
      }
    }
  },
  "ssh_pwauth" => false,
  "packages" => [
    "unifi"
  ],
  "package_update" => false,
  "package_upgrade" => false,
  "package_reboot_if_required" => false,
  "manage_resolv_conf" => false,
  "manage_etc_hosts" => true,
  "fqdn" => "#{node['qemu']['current_config']['hostname']}.lan",
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

include_recipe "qemu-app::_libvirt_common"

include_recipe "qemu-app::_systemd_eth0_static"
include_recipe "qemu-app::_systemd_chef-client"

include_recipe "qemu-app::_deploy_common"
