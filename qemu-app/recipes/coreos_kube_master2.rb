node.default['qemu']['current_config']['hostname'] = 'coreos-kube-master2'

node.default['qemu']['current_config']['memory'] = 2048
node.default['qemu']['current_config']['vcpu'] = 2

include_recipe "qemu-app::_if_lan_static"
include_recipe "qemu-app::_if_store_static"
include_recipe "qemu-app::template_coreos_kube_master"
