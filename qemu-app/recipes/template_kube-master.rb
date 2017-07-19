# node.default['qemu']['current_config']['hostname'] = 'host'
node.default['qemu']['current_config']['cloud_config_path'] = "/data/cloud-init/#{node['qemu']['current_config']['hostname']}"

node.default['qemu']['current_config']['chef_interval'] = '30min'
node.default['qemu']['current_config']['chef_recipes'] = [
  "recipe[system_update::debian]",
  "recipe[kubernetes-app::master]",
]

node.default['qemu']['current_config']['memory'] = 512
node.default['qemu']['current_config']['vcpu'] = 1

node.default['qemu']['current_config']['runcmd'] = [
  'wget -O /tmp/etcd.tar.gz https://github.com/coreos/etcd/releases/download/v3.2.3/etcd-v3.2.3-linux-amd64.tar.gz',
  'tar xzvf /tmp/etcd.tar.gz -C /usr/local/bin --strip-components=1',
  'wget -O /tmp/flannel.tar.gz https://github.com/coreos/flannel/releases/download/v0.8.0/flannel-v0.8.0-linux-amd64.tar.gz',
  'tar xzvf /tmp/flannel.tar.gz -C /usr/local/bin'
]

include_recipe "qemu-app::_cloud_config_common"
include_recipe "qemu-app::_libvirt_common"

include_recipe "qemu-app::_systemd_eth0_static"
include_recipe "qemu-app::_systemd_chef-client"

include_recipe "qemu-app::_deploy_common"
