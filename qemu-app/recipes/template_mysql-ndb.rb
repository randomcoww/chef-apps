# node.default['qemu']['current_config']['hostname'] = 'host'
node.default['qemu']['current_config']['cloud_config_path'] = "/img/cloud-init/#{node['qemu']['current_config']['hostname']}"

node.default['qemu']['current_config']['chef_interval'] = '60min'
node.default['qemu']['current_config']['chef_recipes'] = [
  "recipe[system_update::debian]",
  "recipe[mysql_cluster-app::ndb]",
  "recipe[mysql_cluster-app::api]",
  "recipe[kea-app::dhcp4]",
  "recipe[kea-app::ddns]"
]

node.default['qemu']['current_config']['memory'] = 1
node.default['qemu']['current_config']['vcpu'] = 1

node.default['qemu']['current_config']['runcmd'] = [
  "echo deb http://repo.mysql.com/apt/debian/ jessie mysql-cluster-7.5 >> /etc/apt/sources.list.d/mysql.list",
  "echo deb-src http://repo.mysql.com/apt/debian/ jessie mysql-cluster-7.5 >> /etc/apt/sources.list.d/mysql.list",
  "apt-get -y update"
]

include_recipe "qemu-app::_cloud_config_common"
include_recipe "qemu-app::_libvirt_common"
include_recipe "qemu-app::_systemd_common"
include_recipe "qemu-app::_deploy_common"
