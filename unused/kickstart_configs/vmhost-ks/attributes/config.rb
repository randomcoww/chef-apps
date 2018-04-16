node.default['kickstart']['vmhost']['username'] = 'fedora'
node.default['kickstart']['vmhost']['password'] = 'password'
node.default['kickstart']['vmhost']['groups'] = ['wheel', 'libvirt']
node.default['kickstart']['vmhost']['sshkeys'] = node['environment_v2']['ssh_authorized_keys']['default']

node.default['kickstart']['vmhost']['boot_params'] = %w{
  console=tty0
  console=ttyS1,115200n8
  elevator=noop
  intel_iommu=on
  iommu=pt
  cgroup_enable=memory
}

node.default['kickstart']['vmhost']['packages_install'] = %w{
  @core
  systemd-udev
  which
  ipmitool
  libvirt-daemon-kvm
  libvirt-client
  qemu-kvm
  openssh
  gnupg
  ksm
  nfs-utils
  pciutils
  screen
  dnf-automatic
  lm_sensors
  rkt
  docker
  ca-certificates
  wget
}

node.default['kickstart']['vmhost']['packages_remove'] = %w{
  NetworkManager
  plymouth
  dhclient
  sendmail
  ppc64-utils
}

node.default['kickstart']['vmhost']['services_enable'] = %w{
  systemd-networkd
  systemd-resolved
  ksm
  ksmtuned
  fancontrol
  zfs-import-cache
  zfs-import-scan
  zfs-mount
  zfs-share
  zfs-zed
  zfs.target
  nfs-server
  dnf-automatic-download.timer
  chronyd
  docker
  kubelet
}
