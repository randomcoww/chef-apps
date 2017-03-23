execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'docker' do
  path node['qemu']['docker']['cloud_config_path']
  hostname node['qemu']['docker']['cloud_config_hostname']
  config node['qemu']['docker']['cloud_config']
  systemd_hash node.default['qemu']['docker']['networking']
  action :create
  # notifies :restart, "qemu_domain[docker]", :delayed
end

qemu_domain 'docker' do
  config node['qemu']['docker']['libvirt_config']
  action :start
end
