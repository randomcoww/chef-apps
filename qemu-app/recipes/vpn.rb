execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'vpn' do
  path node['qemu']['vpn']['cloud_config_path']
  hostname node['qemu']['vpn']['cloud_config_hostname']
  config node['qemu']['vpn']['cloud_config']
  systemd_hash node.default['qemu']['vpn']['networking']
  action :create
end

qemu_domain 'vpn' do
  config node['qemu']['vpn']['libvirt_config']
  action :start
end
