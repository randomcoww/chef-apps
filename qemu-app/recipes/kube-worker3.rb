node.default['qemu']['current_config']['hostname'] = 'kube-worker3'
include_recipe "qemu-app::kube-worker"
