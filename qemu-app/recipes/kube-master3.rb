node.default['qemu']['current_config']['hostname'] = 'kube-master3'
include_recipe "qemu-app::template_kube-master"
