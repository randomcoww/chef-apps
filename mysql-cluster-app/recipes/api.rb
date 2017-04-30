execute "pkg_update" do
  command node['mysql-cluster']['pkg_update_command']
  action :run
end

## service starts automatically with default configs on install
## this conflicts with unbound running on default port
## stop until configs are written to run on another port
apt_package node['mysql-cluster']['api']['pkg_names'] do
  action :install
  notifies :stop, "service[mysql]", :immediately
  options [
    '--no-install-recommends',
    '--allow-unauthenticated'
  ]
end

mysql_cluster_config 'api' do
  path '/etc/mysql/my.cnf'
  config node['mysql-cluster']['api']['config']
  action :create
end

include_recipe 'mysql-cluster::service'
