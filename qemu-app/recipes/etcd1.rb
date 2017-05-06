package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'etcd1' do
  path node['qemu']['etcd1']['cloud_config_path']
  hostname node['qemu']['etcd1']['cloud_config_hostname']
  config node['qemu']['etcd1']['cloud_config']
  systemd_hash node.default['qemu']['etcd1']['systemd_config']
  action :create
end

qemu_domain 'etcd1' do
  config node['qemu']['etcd1']['libvirt_config']
  action :start
end
