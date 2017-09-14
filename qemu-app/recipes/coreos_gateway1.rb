node.default['qemu']['current_config']['hostname'] = 'coreos-gateway1'

node.default['qemu']['current_config']['memory'] = 2048
node.default['qemu']['current_config']['vcpu'] = 2

include_recipe "qemu-app::_if_lan_gateway"
include_recipe "qemu-app::_if_wan_gateway"
include_recipe "qemu-app::template_coreos_gateway"
