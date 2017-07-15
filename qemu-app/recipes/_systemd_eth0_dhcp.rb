node.default['qemu']['current_config']['systemd_config']['/etc/systemd/network/50-eth0.network'] = {
  "Match" => {
    "Name" => "eth0"
  },
  "Network" => {
    "LinkLocalAddressing" => "no",
    "DHCP" => "yes",
  },
  "DHCP" => {
    "SendHostname" => "true",
    "UseHostname" => "true",
    "UseDomains" => "true"
  }
}
