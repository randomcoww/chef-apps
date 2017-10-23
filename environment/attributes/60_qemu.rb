node.default['qemu']['config_path'] = '/config/libvirt'

node.default['qemu']['pxe_kernel_path'] = '/data/kvm/coreos_production_pxe.vmlinuz'
node.default['qemu']['pxe_initrd_path'] = '/data/kvm/coreos_production_pxe_image.cpio.gz'

node.default['qemu']['vm1']['guests'] = [
  'coreos-gateway1', 'coreos-gateway2',
  'coreos-etcd1', 'coreos-etcd2', 'coreos-etcd3',
  'coreos-kube-master1',
  'coreos-kube-worker1'
]
