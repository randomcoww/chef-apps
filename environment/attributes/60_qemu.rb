node.default['qemu']['image_path'] = '/data/kvm'
node.default['qemu']['ignition_path'] = '/data/ignition'
node.default['qemu']['config_path'] = '/etc/qemu/libvirt'

node.default['qemu']['libvirt_lan'] = node['environment_v2']['current_host']['if_lan']
node.default['qemu']['libvirt_store'] = node['environment_v2']['current_host']['if_store']

node.default['qemu']['libvirt_network_lan'] = 'passthrough_lan'
node.default['qemu']['libvirt_network_wan'] = 'passthrough_wan'
node.default['qemu']['libvirt_network_store'] = 'passthrough_store'
