node.default['qemu']['current_config']['hostname'] = 'kube-node1'
include_recipe "qemu-app::template_kube-node"
