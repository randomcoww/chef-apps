node.default['qemu']['current_config']['systemd_config']['/etc/systemd/network/50-eth1.network'] = {
  "Match" => {
    "Name" => "eth1"
  },
  "Network" => {
    "LinkLocalAddressing" => "no",
    "DHCP" => "no"
  },
  "Address" => {
    "Address" => "#{node['environment_v2']['host'][node['qemu']['current_config']['hostname']]['ip_store']}/#{node['environment_v2']['subnet']['store'].split('/').last}"
  }
}
