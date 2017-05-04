package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'dns1' do
  path node['qemu']['dns1']['cloud_config_path']
  hostname node['qemu']['dns1']['cloud_config_hostname']
  config node['qemu']['dns1']['cloud_config']
  systemd_hash node.default['qemu']['dns1']['systemd_config']
  action :create
end

qemu_domain 'dns1' do
  config node['qemu']['dns1']['libvirt_config']
  action :start
end
