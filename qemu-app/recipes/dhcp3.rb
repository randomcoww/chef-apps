execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'dhcp3' do
  path node['qemu']['dhcp3']['cloud_config_path']
  hostname node['qemu']['dhcp3']['cloud_config_hostname']
  config node['qemu']['dhcp3']['cloud_config']
  systemd_hash node.default['qemu']['dhcp3']['networking']
  action :create
end

qemu_domain 'dhcp3' do
  config node['qemu']['dhcp3']['libvirt_config']
  action :start
end
