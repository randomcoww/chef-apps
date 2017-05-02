node.default['kea']['mysql']['kea_password'] = Dbag::Keystore.new(
  'deploy_config', 'mysql-cluster'
).get_or_create('kea_password', SecureRandom.hex)

node.default['kea']['mysql']['config'] = {
  "Dhcp4" => {
    "valid-lifetime" => 300,
    # "renew-timer" => 300,
    # "rebind-timer" => 300,
    "interfaces-config" => {
      "interfaces" => [ '*' ]
    },
    "lease-database" => {
      "type" => "mysql",
      "name" => "Kea",
      "host" => "localhost",
      "user" => "Keauser",
      "password" => node['kea']['mysql']['kea_password'],
      "persist" => true
    },
    "subnet4" => [
      {
        "subnet" => node['environment_v2']['subnet']['lan'],
        "option-data" => [
          {
            "name" => "routers",
            "data" => node['environment_v2']['vip']['gateway_lan']
          },
          {
            "name" => "domain-name-servers",
            "data" => [
              node['environment_v2']['vip']['dns_lan'],
              '8.8.8.8'
            ].join(','),
            "csv-format" => true
          }
        ],
        "pools" => [
          {
           "pool" => node['environment_v2']['subnet']['lan_dhcp_pool']
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
        "subnet" => node['environment_v2']['subnet']['vpn'],
        "pools" => [
          {
           "pool" => node['environment_v2']['subnet']['vpn_dhcp_pool']
          }
        ]
      }
    ]
  }
}
