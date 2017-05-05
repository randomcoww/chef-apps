## service starts automatically with default configs on install
## this conflicts with unbound running on default port
## stop until configs are written to run on another port
apt_package node['mysql_cluster']['mgm']['pkg_names'] do
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

mysql_cluster_config 'mgm' do
  path '/var/lib/mysql-cluster/config.ini'
  config node['mysql_cluster']['mgm']['config']
  action :create
end

mysql_cluster_mgm 'mgm_service' do
  options ({
    'config-file' => '/var/lib/mysql-cluster/config.ini',
    'no-nodeid-checks' => true
  })
  action [:enable, :start]
end
