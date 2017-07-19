node.default['kea']['dhcp4_mysql']['create_tables_sql_source'] = 'https://raw.githubusercontent.com/isc-projects/kea/master/src/share/database/scripts/mysql/dhcpdb_create.mysql'

node.default['kea']['lan_reservations'] = {}

node.default['kea']['dhcp4_mysql']['config'] = {
  "Dhcp4" => {
    "valid-lifetime" => 3600,
    "renew-timer" => 3600,
    "rebind-timer" => 3600,
    "interfaces-config" => {
      "interfaces" => [ '*' ]
    },
    "lease-database" => {
      "type" => "mysql",
      "name" => node['mysql_credentials']['kea']['database'],
      "host" => "127.0.0.1",
      "port" => "3306",
      "user" => node['mysql_credentials']['kea']['username'],
      "password" => node['mysql_credentials']['kea']['password'],
      "persist" => true
    },
    "subnet4" => [
      {
        "subnet" => node['environment_v2']['subnet']['lan'],
        "option-data" => [
          {
            "name" => "routers",
            "data" => node['environment_v2']['set']['gateway']['vip_lan']
          },
          {
            "name" => "domain-name-servers",
            "data" => [
              node['environment_v2']['set']['dns']['vip_lan'],
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
    ],
    "dhcp-ddns" => {
      "enable-updates" => true,
      "qualifying-suffix" => "dy.lan",
      "override-client-update" => true,
      "override-no-update" => true,
      "replace-client-name" => "when-not-present"
    }
  }
}
