node.default['system_update']['debian'] = {
  'commands' => [
    "apt-get update -qqy",
    "apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade",
    "apt-get autoremove -y",
    "apt-get clean",
    "apt-get autoclean"
  ],
  'opts' => {
    :timeout => 1000,
    :environment => {
      'DEBIAN_FRONTEND' => 'noninteractive'
    }
  }
}
