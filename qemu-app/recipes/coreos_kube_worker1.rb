node.default['qemu']['current_config']['hostname'] = 'coreos-kube-worker1'
include_recipe "qemu-app::_deploy_coreos"
