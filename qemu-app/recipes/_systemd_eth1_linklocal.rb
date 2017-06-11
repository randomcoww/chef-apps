node.default['qemu']['current_config']['systemd_config']['/etc/systemd/network/eth1.network'] = {
  "Match" => {
    "Name" => "eth1"
  },
  "Network" => {
    "LinkLocalAddressing" => "yes",
    "DHCP" => "no"
  }
}
