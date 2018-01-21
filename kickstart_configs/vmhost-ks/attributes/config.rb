node.default['kickstart']['vmhost']['username'] = 'fedora'
node.default['kickstart']['vmhost']['password'] = 'password'
node.default['kickstart']['vmhost']['groups'] = ['wheel', 'libvirt']
node.default['kickstart']['vmhost']['sshkeys'] = node['environment_v2']['ssh_authorized_keys']['default'].map { |k|
  %Q{sshkey --username=#{node['kickstart']['vmhost']['username']} "#{k}"}
}.join($/)

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
}

# vfio-pci ids=1002:ffffffff:ffffffff:ffffffff:00030000:ffff00ff,1002:ffffffff:ffffffff:ffffffff:00040300:ffffffff,10de:ffffffff:ffffffff:ffffffff:00030000:ffff00ff,10de:ffffffff:ffffffff:ffffffff:00040300:ffffffff
node.default['kickstart']['vmhost']['module_options'] = [
  "kvm ignore_msrs=1",
  "kvm-intel nested=1",
  "igb max_vfs=16",
  "ixgbe max_vfs=16",
]

# set full speed
# ExecStartPre=/usr/bin/ipmitool raw 0x30 0x45 0x01 0x01
# fan control 0x30 0x70 0x66
# get 0x00, set 0x01
# zone FAN 1,2,.. 0x00, FAN A,B,.. 0x01
# duty cycle 0x00-0x64
node.default['kickstart']['vmhost']['systemd_units'] = {
  "fancontrol.service" => {
    "Unit" => {
      "Description" => "Fan Control",
      "After" => "ipmievd.service"
    },
    "Service" => {
      "Type" => "oneshot",
      "ExecStart" => [
        "/usr/bin/ipmitool raw 0x30 0x70 0x66 0x01 0x00 0x18",
        "/usr/bin/ipmitool raw 0x30 0x70 0x66 0x01 0x01 0x18"
      ]
    },
    "Install" => {
      "WantedBy" => "multi-user.target"
    }
  }
}
