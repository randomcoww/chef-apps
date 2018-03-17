host_lan_reservations = []
host_store_reservations = []

node.default['kube_manifests']['kea']['dhcp4_config'] = {
  "Dhcp4" => {
    "valid-lifetime" => 1200,
    "renew-timer" => 1200,
    "rebind-timer" => 1200,
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
    "client-classes" => [
      {
        "name": "ipxe_detected",
        "test": "substring(option[77].hex,0,4) == 'iPXE'",
        "boot-file-name": "http://#{node['environment_v2']['set']['haproxy']['vip']['store']}:48080/boot.ipxe"
      },
      {
        "name": "ipxe",
        "test": "option[93].hex == 0x0000",
        "next-server": node['environment_v2']['set']['pxe']['vip']['store'],
        "boot-file-name": "/undionly.kpxe"
      },
      {
        "name": "ipxe_efi",
        "test": "option[93].hex == 0x0007",
        "next-server": node['environment_v2']['set']['pxe']['vip']['store'],
        "boot-file-name": "/ipxe.efi"
      }
    ],
    "subnet4" => node['environment_v2']['dhcp_pool'].map { |i, pool|

      options = []

      if !node['environment_v2']['set']['gateway']['vip'][i].nil?
        options << {
          "name" => "routers",
          "data" => node['environment_v2']['set']['gateway']['vip'][i]
          # "data" => node['environment_v2']['set']['gateway']['hosts'].map { |e|
          #   node['environment_v2']['host'][e]['ip']['store']
          # }.join(','),
        }
      end

      if !node['environment_v2']['set']['dns']['vip'][i].nil?
        options << {
          "name" => "domain-name-servers",
          # "data" => (node['environment_v2']['set']['dns']['hosts'].map { |e|
          #   node['environment_v2']['host'][e]['ip']['lan']
          # } + [ '8.8.8.8' ]).join(','),
          "data" => [
            node['environment_v2']['set']['dns']['vip'][i],
            '8.8.8.8'
          ].join(','),
          "csv-format" => true
        }
      end

      options << {
        "name" => "domain-name",
        "data" => [
          node['environment_v2']['domain']['host'],
          node['environment_v2']['domain']['top']
        ].join('.')
      }

      {
        "subnet" => node['environment_v2']['subnet'][i],
        "option-data" => options,
        "pools" => [
          {
           "pool" => pool
          }
        ],
        "reservations" => []
      }
    },
    "dhcp-ddns" => {
      "enable-updates" => true,
      "qualifying-suffix" => [
        node['environment_v2']['domain']['host'],
        node['environment_v2']['domain']['top'],
        ''
      ].join('.'),
      "override-client-update" => true,
      "override-no-update" => true,
      "replace-client-name" => "when-not-present"
    }
  }
}
