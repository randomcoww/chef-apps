node.default['qemu']['current_config']['hostname'] = 'coreos-gateway2'
include_recipe "qemu-app::_deploy_coreos"
