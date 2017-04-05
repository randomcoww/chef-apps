execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'gluster2' do
  path node['qemu']['gluster2']['cloud_config_path']
  hostname node['qemu']['gluster2']['cloud_config_hostname']
  config node['qemu']['gluster2']['cloud_config']
  systemd_hash node.default['qemu']['gluster2']['networking']
  action :create
  # notifies :restart, "qemu_domain[docker]", :delayed
end

qemu_domain 'gluster2' do
  config node['qemu']['gluster2']['libvirt_config']
  action :start
end
