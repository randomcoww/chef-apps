node.default['qemu']['current_config']['hostname'] = 'kea-mysql-mgmd'
include_recipe "qemu-app::template_kea-mysql-mgmd"
