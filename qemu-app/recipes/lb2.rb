execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'lb2' do
  path node['qemu']['lb2']['cloud_config_path']
  hostname node['qemu']['lb2']['cloud_config_hostname']
  config node['qemu']['lb2']['cloud_config']
  systemd_hash node.default['qemu']['lb2']['networking']
  action :create
  # notifies :restart, "qemu_domain[lb]", :delayed
end

qemu_domain 'lb2' do
  config node['qemu']['lb2']['libvirt_config']
  action :start
end
