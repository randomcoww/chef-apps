package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'etcd2' do
  path node['qemu']['etcd2']['cloud_config_path']
  hostname node['qemu']['etcd2']['cloud_config_hostname']
  config node['qemu']['etcd2']['cloud_config']
  systemd_hash node.default['qemu']['etcd2']['systemd_config']
  action :create
end

qemu_domain 'etcd2' do
  config node['qemu']['etcd2']['libvirt_config']
  action :start
end
