package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'mysql-ndb1' do
  path node['qemu']['mysql-ndb1']['cloud_config_path']
  hostname node['qemu']['mysql-ndb1']['cloud_config_hostname']
  config node['qemu']['mysql-ndb1']['cloud_config']
  systemd_hash node.default['qemu']['mysql-ndb1']['systemd_config']
  action :create
end

qemu_domain 'mysql-ndb1' do
  config node['qemu']['mysql-ndb1']['libvirt_config']
  action :start
end
