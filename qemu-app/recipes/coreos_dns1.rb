node.default['qemu']['current_config']['hostname'] = 'coreos-dns1'
include_recipe "qemu-app::_deploy_coreos"
