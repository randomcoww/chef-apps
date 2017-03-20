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
    "match-client-id" => false,
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
            "data" => node['environment']['lan_vip_gateway']
          },
          {
            "name" => "domain-name-servers",
            "data" => [
              node['environment']['dns_vip'],
              node['environment']['lan_vip_gateway'],
              '8.8.8.8'
            ].join(','),
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
