execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'lb' do
  path node['qemu']['lb']['cloud_config_path']
  hostname node['qemu']['lb']['cloud_config_hostname']
  config node['qemu']['lb']['cloud_config']
  systemd_hash node.default['qemu']['lb']['networking']
  action :create
  # notifies :restart, "qemu_domain[lb]", :delayed
end

qemu_domain 'lb' do
  config node['qemu']['lb']['libvirt_config']
  action :start
end
