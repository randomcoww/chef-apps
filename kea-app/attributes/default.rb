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
    "option-def" => [
      {
        "name" => "ubnt",
        "code" => 241,
        "space" => "vendor-encapsulated-options-space",
        "type" => "ipv4-address",
        "array" => true
        "encapsulate" => "ubnt"
      }
    ],
    "client-classes" => [
      {
        "name" => "ubnt",
        "test" => "substring(option[60].hex,0,4) == 'ubnt'",
        "option-data" => [
          {
            "name" => "ubnt",
            "space" => "vendor-encapsulated-options-space",
            "code" => 241,
            "data" => "192.168.62.80"
          },
          {
            "name" => "vendor-encapsulated-options"
          }
        ]
      }
    ],
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
            "data" => "192.168.62.250,8.8.8.8",
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
