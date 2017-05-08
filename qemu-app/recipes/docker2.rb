package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'docker2' do
  path node['qemu']['docker2']['cloud_config_path']
  hostname node['qemu']['docker2']['cloud_config_hostname']
  config node['qemu']['docker2']['cloud_config']
  systemd_hash node.default['qemu']['docker2']['systemd_config']
  action :create
end

qemu_domain 'docker2' do
  config node['qemu']['docker2']['libvirt_config']
  action :start
end
