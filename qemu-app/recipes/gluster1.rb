package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'gluster1' do
  path node['qemu']['gluster1']['cloud_config_path']
  hostname node['qemu']['gluster1']['cloud_config_hostname']
  config node['qemu']['gluster1']['cloud_config']
  systemd_hash node.default['qemu']['gluster1']['systemd_config']
  action :create
end

qemu_domain 'gluster1' do
  config node['qemu']['gluster1']['libvirt_config']
  action :start
end
