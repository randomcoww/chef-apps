node.default['qemu']['current_config']['hostname'] = 'kube-worker4'
include_recipe "qemu-app::kube-worker"
