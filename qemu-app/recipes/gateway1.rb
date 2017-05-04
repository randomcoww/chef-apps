package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'gateway1' do
  path node['qemu']['gateway1']['cloud_config_path']
  hostname node['qemu']['gateway1']['cloud_config_hostname']
  config node['qemu']['gateway1']['cloud_config']
  systemd_hash node.default['qemu']['gateway1']['systemd_config']
  action :create
end

qemu_domain 'gateway1' do
  config node['qemu']['gateway1']['libvirt_config']
  action :start
end
