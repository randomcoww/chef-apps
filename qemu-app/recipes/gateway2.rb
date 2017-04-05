execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'gateway2' do
  path node['qemu']['gateway2']['cloud_config_path']
  hostname node['qemu']['gateway2']['cloud_config_hostname']
  config node['qemu']['gateway2']['cloud_config']
  systemd_hash node.default['qemu']['gateway2']['networking']
  action :create
  # notifies :restart, "qemu_domain[gateway]", :delayed
end

qemu_domain 'gateway2' do
  config node['qemu']['gateway2']['libvirt_config']
  action :start
end
