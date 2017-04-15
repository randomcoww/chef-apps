execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'dns2' do
  path node['qemu']['dns2']['cloud_config_path']
  hostname node['qemu']['dns2']['cloud_config_hostname']
  config node['qemu']['dns2']['cloud_config']
  systemd_hash node.default['qemu']['dns2']['networking']
  action :create
  # notifies :restart, "qemu_domain[lb]", :delayed
end

qemu_domain 'dns2' do
  config node['qemu']['dns2']['libvirt_config']
  action :start
end
