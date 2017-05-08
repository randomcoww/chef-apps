package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'docker1' do
  path node['qemu']['docker1']['cloud_config_path']
  hostname node['qemu']['docker1']['cloud_config_hostname']
  config node['qemu']['docker1']['cloud_config']
  systemd_hash node.default['qemu']['docker1']['systemd_config']
  action :create
end

qemu_domain 'docker1' do
  config node['qemu']['docker1']['libvirt_config']
  action :start
end
