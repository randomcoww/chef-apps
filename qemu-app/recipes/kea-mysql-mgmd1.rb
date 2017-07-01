node.default['qemu']['current_config']['hostname'] = 'kea-mysql-mgmd1'
include_recipe "qemu-app::template_kea-mysql-mgmd"
