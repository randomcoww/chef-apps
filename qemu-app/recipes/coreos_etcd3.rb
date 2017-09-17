node.default['qemu']['current_config']['hostname'] = 'coreos-etcd3'
include_recipe "qemu-app::_deploy_coreos"
