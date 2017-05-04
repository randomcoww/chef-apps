package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'transmission' do
  path node['qemu']['transmission']['cloud_config_path']
  hostname node['qemu']['transmission']['cloud_config_hostname']
  config node['qemu']['transmission']['cloud_config']
  systemd_hash node.default['qemu']['transmission']['systemd_config']
  action :create
end

qemu_domain 'transmission' do
  config node['qemu']['transmission']['libvirt_config']
  action :start
end
