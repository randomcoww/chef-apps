execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'mysql-mgm' do
  path node['qemu']['mysql-mgm']['cloud_config_path']
  hostname node['qemu']['mysql-mgm']['cloud_config_hostname']
  config node['qemu']['mysql-mgm']['cloud_config']
  systemd_hash node.default['qemu']['mysql-mgm']['networking']
  action :create
  # notifies :restart, "qemu_domain[lb]", :delayed
end

qemu_domain 'mysql-mgm' do
  config node['qemu']['mysql-mgm']['libvirt_config']
  action :start
end
