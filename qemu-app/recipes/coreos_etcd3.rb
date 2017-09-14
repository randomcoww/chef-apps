node.default['qemu']['current_config']['hostname'] = 'coreos-etcd3'

node.default['qemu']['current_config']['memory'] = 1024
node.default['qemu']['current_config']['vcpu'] = 2

include_recipe "qemu-app::_if_lan_static"
include_recipe "qemu-app::template_coreos_etcd"
