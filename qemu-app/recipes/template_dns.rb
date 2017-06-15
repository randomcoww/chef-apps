# node.default['qemu']['current_config']['hostname'] = 'host'
node.default['qemu']['current_config']['cloud_config_path'] = "/img/cloud-init/#{node['qemu']['current_config']['hostname']}"

node.default['qemu']['current_config']['chef_interval'] = '10min'
node.default['qemu']['current_config']['chef_recipes'] = [
  "recipe[system_update::debian]",
  "recipe[keepalived-app::dns]",
  "recipe[knot-app::main]",
  "recipe[unbound-app::main]",
  "recipe[openvpn-app::pia_client]"
]

node.default['qemu']['current_config']['memory'] = 256
node.default['qemu']['current_config']['vcpu'] = 1

node.default['qemu']['current_config']['runcmd'] = [
  "apt-get -y install apt-transport-https ca-certificates",
  "wget -O - https://deb.knot-dns.cz/knot/apt.gpg | apt-key add -",

  "echo deb https://deb.knot-dns.cz/knot/ $(lsb_release -sc) main > /etc/apt/sources.list.d/knot.list",
  "apt-get -y update"
]

include_recipe "qemu-app::_cloud_config_common"
include_recipe "qemu-app::_libvirt_common"

include_recipe "qemu-app::_systemd_eth0_static"
include_recipe "qemu-app::_systemd_chef-client"

include_recipe "qemu-app::_deploy_common"
