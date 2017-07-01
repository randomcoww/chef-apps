node.default['qemu']['current_config']['hostname'] = 'kea-mysql-mgmd2'
include_recipe "qemu-app::template_kea-mysql-mgmd"
