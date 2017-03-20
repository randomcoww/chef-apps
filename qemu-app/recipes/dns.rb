execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'dns' do
  path node['qemu']['dns']['cloud_config_path']
  hostname node['qemu']['dns']['cloud_config_hostname']
  config node['qemu']['dns']['cloud_config']
  systemd_hash node.default['qemu']['dns']['networking']
  action :create
  # notifies :restart, "qemu_domain[dns]", :delayed
end

qemu_domain 'dns' do
  config node['qemu']['dns']['libvirt_config']
  action :start
end
