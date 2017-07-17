node.default['qemu']['pkg_names'] = ['build-essential', 'pkg-config', 'libvirt-dev']
node.default['qemu']['libvirt_network_lan'] = 'passthrough_lan'
node.default['qemu']['libvirt_network_wan'] = 'passthrough_wan'
node.default['qemu']['libvirt_network_store'] = 'passthrough_store'
