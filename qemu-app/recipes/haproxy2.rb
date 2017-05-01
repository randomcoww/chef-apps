execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'haproxy2' do
  path node['qemu']['haproxy2']['cloud_config_path']
  hostname node['qemu']['haproxy2']['cloud_config_hostname']
  config node['qemu']['haproxy2']['cloud_config']
  systemd_hash node.default['qemu']['haproxy2']['networking']
  action :create
  # notifies :restart, "qemu_domain[lb]", :delayed
end

qemu_domain 'haproxy2' do
  config node['qemu']['haproxy2']['libvirt_config']
  action :start
end
