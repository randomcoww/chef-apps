node.default['qemu']['image_path'] = '/data/kvm'
node.default['qemu']['ignition_path'] = '/data/ignition'
node.default['qemu']['config_path'] = '/config/libvirt'

node.default['qemu']['libvirt_network_lan'] = 'passthrough_lan'
node.default['qemu']['libvirt_network_wan'] = 'passthrough_wan'
node.default['qemu']['libvirt_network_store'] = 'passthrough_store'

node.default['qemu']['gateway']['hosts'] = node['environment_v2']['set']['gateway']['hosts']
node.default['qemu']['generic']['hosts'] = node['environment_v2']['set']['dns']['hosts'] +
  node['environment_v2']['set']['kea']['hosts'] +
  node['environment_v2']['set']['kube-master']['hosts'] +
  node['environment_v2']['set']['kube-worker']['hosts'] +
  node['environment_v2']['set']['etcd']['hosts']

node.default['qemu']['vm1']['guests'] = [
  'coreos-dns1', 'coreos-dns2',
  'coreos-gateway1', 'coreos-gateway2',
  'coreos-etcd1', 'coreos-etcd2', 'coreos-etcd3',
  'coreos-kube-master1',
  'coreos-kube-master2',
  'coreos-kube-worker1', 'coreos-kube-worker2'
]
