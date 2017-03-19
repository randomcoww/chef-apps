execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'unifi' do
  path node['qemu']['unifi']['cloud_config_path']
  hostname node['qemu']['unifi']['cloud_config_hostname']
  config node['qemu']['unifi']['cloud_config']
  systemd_hash node.default['qemu']['unifi']['networking']
  action :create
  # notifies :restart, "qemu_domain[unifi]", :delayed
end

qemu_domain 'unifi' do
  config node['qemu']['unifi']['libvirt_config']
  action :start
end
