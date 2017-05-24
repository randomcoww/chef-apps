package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'kube-worker1' do
  path node['qemu']['kube-worker1']['cloud_config_path']
  hostname node['qemu']['kube-worker1']['cloud_config_hostname']
  config node['qemu']['kube-worker1']['cloud_config']
  systemd_hash node.default['qemu']['kube-worker1']['systemd_config']
  action :create
end

qemu_domain 'kube-worker1' do
  config node['qemu']['kube-worker1']['libvirt_config']
  action :start
end
