node.default['qemu']['image_path'] = '/data/kvm'
node.default['qemu']['ignition_path'] = '/data/ignition'
node.default['qemu']['config_path'] = '/config/libvirt'

node.default['qemu']['libvirt_network_lan'] = 'passthrough_lan'
node.default['qemu']['libvirt_network_wan'] = 'passthrough_wan'
node.default['qemu']['libvirt_network_store'] = 'passthrough_store'
