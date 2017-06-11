node.default['qemu']['current_config']['systemd_static_network']['/etc/systemd/network/eth0.network'] = {
  "Match" => {
    "Name" => "eth0"
  },
  "Network" => {
    "LinkLocalAddressing" => "no",
    "DHCP" => "no",
    "DNS" => [
      node['environment_v2']['set']['dns']['vip_lan'],
      "8.8.8.8"
    ]
  },
  "Address" => {
    "Address" => "#{node['environment_v2']['host'][node['qemu']['current_config']['hostname']]['ip_lan']}/#{node['environment_v2']['subnet']['lan'].split('/').last}"
  },
  "Route" => {
    "Gateway" => node['environment_v2']['set']['gateway']['vip_lan'],
  }
}
