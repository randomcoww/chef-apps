node.default['kea']['cql']['kea_config'] = {
  "Dhcp4" => {
    "valid-lifetime" => 300,
    "interfaces-config" => {
      "interfaces" => [ '*' ]
    },
    "lease-database" => {
      "type" => "cql",
      "persist" => true
    },
    "subnet4" => [
      {
        "subnet" => node['environment_v2']['lan_subnet'],
        "option-data" => [
          {
            "name" => "routers",
            "data" => node['environment_v2']['gateway_lan_vip']
          },
          {
            "name" => "domain-name-servers",
            "data" => [
              node['environment_v2']['dns_lan_vip'],
              '8.8.8.8'
            ].join(','),
            "csv-format" => true
          }
        ],
        "pools" => [
          {
           "pool" => node['environment_v2']['lan_dhcp_pool']
          }
        ],
        "reservations" => node['kea']['lan_reservations'].map { |k, v|
          {
            "hw-address" => k,
            "ip-address" => v
          }
        }
      },
      {
        "subnet" => node['environment_v2']['vpn_subnet'],
        "pools" => [
          {
           "pool" => node['environment_v2']['vpn_dhcp_pool1']
          }
        ]
      }
    ]
  }
}
