# node.default['qemu']['current_config']['hostname'] = 'host'
node.default['qemu']['current_config']['cloud_config_path'] = "/data/cloud-init/#{node['qemu']['current_config']['hostname']}"

node.default['qemu']['current_config']['chef_interval'] = '10min'
node.default['qemu']['current_config']['chef_recipes'] = [
  "recipe[system_update::debian]",
  "recipe[kubelet-app::master]"
]

node.default['qemu']['current_config']['memory'] = 2048
node.default['qemu']['current_config']['vcpu'] = 1

node.default['qemu']['current_config']['runcmd'] = []

include_recipe "qemu-app::_cloud_config_common"
include_recipe "qemu-app::_libvirt_common"

include_recipe "qemu-app::_systemd_eth0_static"
include_recipe "qemu-app::_systemd_chef-client"

include_recipe "qemu-app::_deploy_common"
