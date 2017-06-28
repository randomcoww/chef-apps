# node.default['qemu']['current_config']['hostname'] = 'host'
node.default['qemu']['current_config']['cloud_config_path'] = "/img/cloud-init/#{node['qemu']['current_config']['hostname']}"

node.default['qemu']['current_config']['chef_interval'] = '60min'
node.default['qemu']['current_config']['chef_recipes'] = [
  "recipe[system_update::debian]",
  "recipe[nftables-app::filter]",
  "recipe[transmission-app::main]",
  "recipe[openvpn-app::pia_client]"
]

node.default['qemu']['current_config']['memory'] = 1024
node.default['qemu']['current_config']['vcpu'] = 2

node.default['qemu']['current_config']['runcmd'] = [
  "apt-get -y install glusterfs-client"
]

include_recipe "qemu-app::_cloud_config_common"
include_recipe "qemu-app::_libvirt_common"

include_recipe "qemu-app::_systemd_eth0_dhcp"
include_recipe "qemu-app::_systemd_eth1_linklocal"
include_recipe "qemu-app::_systemd_chef-client"

include_recipe "qemu-app::_deploy_common"
