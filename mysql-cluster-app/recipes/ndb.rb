execute "pkg_update" do
  command node['mysql-cluster']['pkg_update_command']
  action :run
end

## service starts automatically with default configs on install
## this conflicts with unbound running on default port
## stop until configs are written to run on another port
apt_package node['mysql-cluster']['ndb']['pkg_names'] do
  action :install
  # notifies :stop, "service[mysql]", :immediately
  options [
    '--no-install-recommends',
    '--allow-unauthenticated'
  ]
end

directory "/var/lib/mysql-cluster" do
  recursive true
  action :create
end

mysql_cluster_ndb 'ndb_service' do
  options node['mysql-cluster']['ndb']['options']
  action [:enable, :start]
end
