node.default['keepalived']['package'] = 'keepalived'

node.default['keepalived']['gateway']['auth_data_bag'] = 'deploy_config'
node.default['keepalived']['gateway']['auth_data_bag_item'] = 'keepalived'

node.default['keepalived']['dns']['auth_data_bag'] = 'deploy_config'
node.default['keepalived']['dns']['auth_data_bag_item'] = 'keepalived'
