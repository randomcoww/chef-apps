node.default['qemu']['current_config']['hostname'] = 'mysql-ndb2'
include_recipe "qemu-app::template_mysql-ndb"
