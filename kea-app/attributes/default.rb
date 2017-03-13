node.default['kea']['pkg_update_command'] = "apt-get update -qqy"
node.default['kea']['pkg_names'] = ['kea-dhcp4-server']
node.default['kea']['dhcp4_config'] = {
  "Dhcp4" => {
    "valid-lifetime" => 4000,
    "renew-timer" => 1000,
    "rebind-timer" => 2000,
    "interfaces-config" => {
      "interfaces" => [ '*' ]
    },
    "lease-database" => {
      "type" => "memfile",
      "persist" => true
    },
    "subnet4" => [
      {
        "subnet" => node['environment']['lan_subnet'],
        "option-data" => [
          {
            "name" => "routers",
            "data" => node['environment']['lan_ip_gateway']
          },
          {
            "name" => "domain-name-servers",
            "data" => "#{node['environment']['dns_ip']},8.8.8.8",
            "csv-format" => true
          }
        ],
        "pools" => [
          {
           "pool" => node['environment']['lan_subnet_dhcp']
          }
        ]
      },
      {
        "subnet" => node['environment']['vpn_subnet'],
        "pools" => [
          {
           "pool" => node['environment']['vpn_subnet_dhcp']
          }
        ]
      }
    ]
  }
}
