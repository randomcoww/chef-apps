current_host = node['qemu']['current_config']['hostname']
interface = node['environment_v2']['host'][current_host]['if_store']

node.default['qemu']['current_config']['networking'][name] = {
  "Match" => {
    "Name" => interface
  },
  "Network" => {
    "LinkLocalAddressing" => "no",
    "DHCP" => "yes",
    "DNS" => (node['environment_v2']['set']['dns']['hosts'].map { |host|
      node['environment_v2']['host'][host]['ip_lan']
    } + [ '8.8.8.8' ])
  },
  "DHCP" => {
    "UseDNS" => "false",
    "UseNTP" => "false",
    "SendHostname" => "false",
    "UseHostname" => "false",
    "UseDomains" => "false",
    "UseTimezone" => "no",
    "RouteMetric" => 1024,
    # "IPMasquerade" => "yes",
    # "IPForward" => "ipv4"
  }
}
