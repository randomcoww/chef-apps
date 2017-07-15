node.default['qemu']['current_config']['systemd_config']['/etc/systemd/network/50-eth1.network'] = {
  "Match" => {
    "Name" => "eth1"
  },
  "Network" => {
    "LinkLocalAddressing" => "yes",
    "DHCP" => "no"
  }
}
