package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config node['qemu']['current_config']['hostname'] do
  path node['qemu']['current_config']['cloud_config_path']
  hostname node['qemu']['current_config']['hostname']
  config node['qemu']['current_config']['cloud_config']
  systemd_hash node['qemu']['current_config']['systemd_config']
  action :create
end

qemu_domain node['qemu']['current_config']['hostname'] do
  config node['qemu']['current_config']['libvirt_config']
  action :start
end
