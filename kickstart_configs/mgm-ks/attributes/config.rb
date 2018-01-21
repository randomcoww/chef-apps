node.default['kickstart']['mgm']['username'] = 'fedora'
node.default['kickstart']['mgm']['password'] = 'password'
node.default['kickstart']['mgm']['groups'] = ['wheel', 'libvirt']
node.default['kickstart']['mgm']['sshkeys'] = node['environment_v2']['ssh_authorized_keys']['default'].map { |k|
  %Q{sshkey --username=#{node['kickstart']['mgm']['username']} "#{k}"}
}.join($/)

node.default['kickstart']['mgm']['boot_params'] = %w{
  elevator=noop
}

node.default['kickstart']['mgm']['packages_install'] = %w{
  @core
  systemd-udev
  which
  ipmitool
  openssh
  gnupg
  pciutils
  screen
  dnf-automatic
}

node.default['kickstart']['mgm']['packages_remove'] = %w{
  NetworkManager
  plymouth
  dhclient
  sendmail
  ppc64-utils
}

node.default['kickstart']['mgm']['services_enable'] = %w{
  systemd-networkd
  systemd-resolved
  dnf-automatic-download.timer
}
