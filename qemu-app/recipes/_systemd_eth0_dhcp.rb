node.default['qemu']['current_config']['systemd_config']['/etc/systemd/network/eth0.network'] = {
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
