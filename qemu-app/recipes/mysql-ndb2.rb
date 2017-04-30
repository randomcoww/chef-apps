execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'mysql-ndb2' do
  path node['qemu']['mysql-ndb2']['cloud_config_path']
  hostname node['qemu']['mysql-ndb2']['cloud_config_hostname']
  config node['qemu']['mysql-ndb2']['cloud_config']
  systemd_hash node.default['qemu']['mysql-ndb2']['networking']
  action :create
  # notifies :restart, "qemu_domain[lb]", :delayed
end

qemu_domain 'mysql-ndb2' do
  config node['qemu']['mysql-ndb2']['libvirt_config']
  action :start
end
