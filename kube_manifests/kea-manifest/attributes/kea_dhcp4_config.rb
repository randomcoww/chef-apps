host_lan_reservations = []
host_store_reservations = []

node['environment_v2']['host'].each do |hostname, d|

  if d.has_key?('mac_lan') &&
    d.has_key?('ip_lan')

    host_lan_reservations << {
      'hw-address' => d['mac_lan'],
      'ip-address' => d['ip_lan'],
      'hostname' => hostname
    }
  end

  if d.has_key?('mac_store') &&
    d.has_key?('ip_store')

    host_lan_reservations << {
      'hw-address' => d['mac_store'],
      'ip-address' => d['ip_store'],
      'hostname' => hostname
    }
  end
end


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
              node['environment_v2']['set']['ns']['vip_lan'],
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
        "reservations" => host_lan_reservations
      },
      {
        "subnet" => node['environment_v2']['subnet']['store'],
        "pools" => [
          {
           "pool" => node['environment_v2']['subnet']['store_dhcp_pool']
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
