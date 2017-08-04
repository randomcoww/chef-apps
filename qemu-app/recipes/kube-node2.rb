node.default['qemu']['current_config']['hostname'] = 'kube-node2'
include_recipe "qemu-app::template_kube-node"
