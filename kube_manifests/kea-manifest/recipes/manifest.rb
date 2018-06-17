env_vars = node['environment_v2']['set']['kea']['vars']

# nextserver = node['environment_v2']['host'][host]['ip']['store']
host_lan_reservations = []
host_store_reservations = []

kea_dhcp4_config = {
  "Dhcp4" => {
    "valid-lifetime" => 1200,
    "renew-timer" => 1200,
    "rebind-timer" => 1200,
    "interfaces-config" => {
      "interfaces" => [ '*' ]
    },
    "lease-database" => {
      "type": "memfile",
      "name": ::File.join(env_vars["lease_path"], "dhcp4.leases"),
      "persist" => true
    },
    "client-classes" => [
      {
        "name" => "ipxe_detected",
        "test" => "substring(option[77].hex,0,4) == 'iPXE'",
        "boot-file-name" => "http://#{node['environment_v2']['set']['matchbox']['vip']['store']}:#{node['environment_v2']['port']['matchbox-http']}/boot.ipxe"
      },
      {
        "name" => "ipxe",
        "test" => "not(substring(option[77].hex,0,4) == 'iPXE') and (option[93].hex == 0x0000)",
        "next-server" => node['environment_v2']['set']['matchbox']['vip']['store'],
        "boot-file-name" => "/undionly.kpxe"
      },
      {
        "name" => "ipxe_efi",
        "test" => "not(substring(option[77].hex,0,4) == 'iPXE') and (option[93].hex == 0x0007)",
        "next-server" => node['environment_v2']['set']['matchbox']['vip']['store'],
        "boot-file-name" => "/ipxe.efi"
      }
    ],
    "subnet4" => node['environment_v2']['dhcp_pool'].map { |i, pool|

      options = []

      if !node['environment_v2']['set']['gateway']['vip'][i].nil?
        options << {
          "name" => "routers",
          "data" => node['environment_v2']['set']['gateway']['vip'][i]
        }
      end

      if !node['environment_v2']['set']['dns']['vip'][i].nil?
        options << {
          "name" => "domain-name-servers",
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

kea_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kea-mysql"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "kea-dhcp4",
        "image" => node['kube']['images']['kea_dhcp4'],
        "args" => [
          "kea-dhcp4"
        ],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => JSON.pretty_generate(kea_dhcp4_config)
          }
        ],
        "volumeMounts" => [
          {
            "name" => "lease-path",
            "mountPath" => env_vars["lease_path"],
            "readOnly" => false
          }
        ]
      }
    ],
    "volumes" => [
      {
        "name" => "lease-path",
        # "nfs" => {
        #   "server" => node['environment_v2']['set']['nfs']['vip']['store'],
        #   "path" => env_vars["mount_path"]
        # }
        # "hostPath" => {
        #   "path" => env_vars["lease_path"]
        # }
        "emptyDir" => {}
      }
    ]
  }
}

# kea nodes
node['environment_v2']['set']['kea']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['kea'] = kea_manifest
end
