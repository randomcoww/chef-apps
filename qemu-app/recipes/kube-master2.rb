node.default['qemu']['current_config']['hostname'] = 'kube-master2'
include_recipe "qemu-app::template_kube-master"
