## deprecated

# kea_mysql_seed 'seed' do
#   url 'https://raw.githubusercontent.com/randomcoww/chef-apps/master/container/kea-pod/files/default/mysql_cluster_seed.sql'
#   options ({
#     username: node['mysql_credentials']['kea']['username'],
#     password: node['mysql_credentials']['kea']['password'],
#     database: node['mysql_credentials']['kea']['database'],
#     host: '127.0.0.1',
#     port: 3306
#   })
#   action :create
# end
