node.default['qemu']['current_config']['hostname'] = 'mysql-mgm'
include_recipe "qemu-app::template_mysql-mgm"
