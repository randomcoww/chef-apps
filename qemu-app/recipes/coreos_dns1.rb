node.default['qemu']['current_config']['hostname'] = 'coreos-dns1'

node.default['qemu']['current_config']['memory'] = 2048
node.default['qemu']['current_config']['vcpu'] = 2

node.default['qemu']['current_config']['libvirt_networks'] = [
  node['qemu']['libvirt_network_lan']
]

include_recipe "qemu-app::_if_lan_static"
include_recipe "qemu-app::template_coreos_kube_worker"
