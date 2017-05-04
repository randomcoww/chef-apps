package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'mysql-mgm' do
  path node['qemu']['mysql-mgm']['cloud_config_path']
  hostname node['qemu']['mysql-mgm']['cloud_config_hostname']
  config node['qemu']['mysql-mgm']['cloud_config']
  systemd_hash node.default['qemu']['mysql-mgm']['systemd_config']
  action :create
end

qemu_domain 'mysql-mgm' do
  config node['qemu']['mysql-mgm']['libvirt_config']
  action :start
end
