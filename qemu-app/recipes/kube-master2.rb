package node['qemu']['pkg_names'] do
  action :upgrade
end

include_recipe "qemu::install"

qemu_cloud_config 'kube-master2' do
  path node['qemu']['kube-master2']['cloud_config_path']
  hostname node['qemu']['kube-master2']['cloud_config_hostname']
  config node['qemu']['kube-master2']['cloud_config']
  systemd_hash node.default['qemu']['kube-master2']['systemd_config']
  action :create
end

qemu_domain 'kube-master2' do
  config node['qemu']['kube-master2']['libvirt_config']
  action :start
end
