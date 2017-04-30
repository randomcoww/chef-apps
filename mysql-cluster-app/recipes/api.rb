execute "pkg_update" do
  command node['mysql-cluster']['pkg_update_command']
  action :run
end

bash "debconf_root-pass" do
  code %Q{debconf-set-selections <<< "mysql-cluster-community-server mysql-cluster-community-server/root-pass password #{node['mysql-cluster']['api']['root_password']}"}
  action :nothing
end

bash "debconf_re-root-pass" do
  code %Q{debconf-set-selections <<< "mysql-cluster-community-server mysql-cluster-community-server/re-root-pass password #{node['mysql-cluster']['api']['root_password']}"}
  action :nothing
end

## service starts automatically with default configs on install
## this conflicts with unbound running on default port
## stop until configs are written to run on another port
apt_package node['mysql-cluster']['api']['pkg_names'] do
  action :install
  options [
    '--no-install-recommends',
    '--allow-unauthenticated'
  ]
  notifies :run, "bash[debconf_root-pass]", :before
  notifies :run, "bash[debconf_re-root-pass]", :before
  notifies :stop, "service[mysql]", :immediately
end

mysql_cluster_config 'api' do
  path '/etc/mysql/my.cnf'
  config node['mysql-cluster']['api']['config']
  action :create
end

include_recipe 'mysql-cluster::service'
