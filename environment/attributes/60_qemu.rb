node.default['qemu']['config_path'] = '/config/libvirt'

node.default['qemu']['pxe_kernel_path'] = '/data/pxe/coreos_production_pxe.vmlinuz'
node.default['qemu']['pxe_initrd_path'] = '/data/pxe/coreos_production_pxe_image.cpio.gz'

node.default['qemu']['generic']['hosts'] = node['environment_v2']['set']['gateway']['hosts'] +
  node['environment_v2']['set']['kube-master']['hosts'] +
  node['environment_v2']['set']['kube-worker']['hosts'] +
  node['environment_v2']['set']['etcd']['hosts']

node.default['qemu']['vm1']['guests'] = [
  'coreos-gateway1', 'coreos-gateway2',
  'coreos-etcd1', 'coreos-etcd2', 'coreos-etcd3',
  'coreos-kube-master1',
  'coreos-kube-master2',
  'coreos-kube-worker1', 'coreos-kube-worker2'
]
