node.default['qemu']['current_config']['hostname'] = 'coreos-kube-master1'
include_recipe "qemu-app::_deploy_coreos"
