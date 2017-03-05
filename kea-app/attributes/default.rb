node.default['kea']['pkg_update_command'] = "apt-get update -qqy"
node.default['kea']['pkg_names'] = ['git', 'kea-dhcp4-server', 'kea-dhcp6-server', 'kea-dhcp-ddns-server']
node.default['kea']['instances']['primary'] = {
  'config' => {
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
              "data" => node['environment']['lan_vip_gateway']
            },
            {
              "name" => "domain-name-servers",
              "data" => node['environment']['lan_vip_gateway']
            }
          ],
          "pools" => [
            {
             "pool" => node['environment']['lan_subnet_dhcp']
            }
          ]
        }
      ]
    }
  }
}
