node.default['qemu']['current_config']['hostname'] = 'coreos-kube-master2'
include_recipe "qemu-app::_deploy_coreos"
