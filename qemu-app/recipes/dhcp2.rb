execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'dhcp2' do
  path node['qemu']['dhcp2']['cloud_config_path']
  hostname node['qemu']['dhcp2']['cloud_config_hostname']
  config node['qemu']['dhcp2']['cloud_config']
  systemd_hash node.default['qemu']['dhcp2']['networking']
  action :create
end

qemu_domain 'dhcp2' do
  config node['qemu']['dhcp2']['libvirt_config']
  action :start
end
