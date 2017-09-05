node.default['qemu']['current_config']['hostname'] = 'coreos-dns1'

node.default['qemu']['current_config']['memory'] = 2048
node.default['qemu']['current_config']['vcpu'] = 2

include_recipe "qemu-app::template_coreos_kube_worker"
