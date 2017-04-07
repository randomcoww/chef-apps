execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'gluster-client' do
  path node['qemu']['gluster-client']['cloud_config_path']
  hostname node['qemu']['gluster-client']['cloud_config_hostname']
  config node['qemu']['gluster-client']['cloud_config']
  systemd_hash node.default['qemu']['gluster-client']['networking']
  action :create
end

qemu_domain 'gluster-client' do
  config node['qemu']['gluster-client']['libvirt_config']
  action :start
end
