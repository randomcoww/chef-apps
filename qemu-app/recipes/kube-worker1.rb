node.default['qemu']['current_config']['hostname'] = 'kube-worker1'
include_recipe "qemu-app::template_kube-worker"
