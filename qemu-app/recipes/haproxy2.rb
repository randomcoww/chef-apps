package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'haproxy2' do
  path node['qemu']['haproxy2']['cloud_config_path']
  hostname node['qemu']['haproxy2']['cloud_config_hostname']
  config node['qemu']['haproxy2']['cloud_config']
  systemd_hash node.default['qemu']['haproxy2']['systemd_config']
  action :create
end

qemu_domain 'haproxy2' do
  config node['qemu']['haproxy2']['libvirt_config']
  action :start
end
