host_lan_reservations = []
host_store_reservations = []

node.default['kube_manifests']['kea']['dhcp4_config'] = {
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
      "port" => 3306,
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
            # "data" => (node['environment_v2']['set']['ns']['hosts'].map { |e|
            #   node['environment_v2']['host'][e]['ip_lan']
            # } + [ '8.8.8.8' ]).join(','),
            "data" => [
              node['environment_v2']['set']['ns']['vip_lan'],
              '8.8.8.8'
            ].join(','),
            "csv-format" => true
          }
        ],
        "pools" => [
          {
           "pool" => node['environment_v2']['subnet']['dhcp_pool_lan']
          }
        ],
        "reservations" => host_lan_reservations
      },
      {
        "subnet" => node['environment_v2']['subnet']['store'],
        "pools" => [
          {
           "pool" => node['environment_v2']['subnet']['dhcp_pool_store']
          }
        ],
        "reservations" => host_store_reservations
      }
    ],
    "dhcp-ddns" => {
      "enable-updates" => true,
      "qualifying-suffix" => [
        node['environment_v2']['domain']['host_lan'],
        node['environment_v2']['domain']['top'],
        ''
      ].join('.'),
      "override-client-update" => true,
      "override-no-update" => true,
      "replace-client-name" => "when-not-present"
    }
  }
}
