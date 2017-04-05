execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'gateway1' do
  path node['qemu']['gateway1']['cloud_config_path']
  hostname node['qemu']['gateway1']['cloud_config_hostname']
  config node['qemu']['gateway1']['cloud_config']
  systemd_hash node.default['qemu']['gateway1']['networking']
  action :create
  # notifies :restart, "qemu_domain[gateway]", :delayed
end

qemu_domain 'gateway1' do
  config node['qemu']['gateway1']['libvirt_config']
  action :start
end
