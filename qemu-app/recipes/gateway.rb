execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'gateway' do
  path node['qemu']['gateway']['cloud_config_path']
  hostname node['qemu']['gateway']['cloud_config_hostname']
  config node['qemu']['gateway']['cloud_config']
  action :create
  notifies :restart, "qemu_domain[gateway]", :delayed
end

qemu_domain 'gateway' do
  config node['qemu']['gateway']['libvirt_config']
  action :start
end
