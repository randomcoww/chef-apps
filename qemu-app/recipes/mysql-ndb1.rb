node.default['qemu']['current_config']['hostname'] = 'mysql-ndb1'
include_recipe "qemu-app::template_mysql-ndb"
