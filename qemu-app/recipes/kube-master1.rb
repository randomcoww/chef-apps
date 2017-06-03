node.default['qemu']['current_config']['hostname'] = 'kube-master1'
include_recipe "qemu-app::template_kube-master"
