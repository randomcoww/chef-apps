# node.default['qemu']['current_config']['hostname'] = 'host'
node.default['qemu']['current_config']['cloud_config_path'] = "/img/cloud-init/#{node['qemu']['current_config']['hostname']}"

node.default['qemu']['current_config']['chef_interval'] = '60min'
node.default['qemu']['current_config']['chef_recipes'] = [
  "recipe[system_update::debian]"
]

node.default['qemu']['current_config']['memory'] = 1
node.default['qemu']['current_config']['vcpu'] = 1

node.default['qemu']['current_config']['runcmd'] = [
  'apt-get -y install apt-transport-https ca-certificates gnupg2 dirmngr',
  'apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50',
  'echo "deb http://www.ubnt.com/downloads/unifi/debian unifi5 ubiquiti" > /etc/apt/sources.list.d/100-ubnt.list',
  "apt-get -y update",
  "apt-get -y install --no-install-recommends unifi",
  "systemctl disable mongodb",
  "systemctl start unifi",
  "systemctl enable unifi"
]

include_recipe "qemu-app::_cloud_config_common"
include_recipe "qemu-app::_libvirt_common"

include_recipe "qemu-app::_systemd_eth0_dhcpc"
include_recipe "qemu-app::_systemd_chef-client"

include_recipe "qemu-app::_deploy_common"
