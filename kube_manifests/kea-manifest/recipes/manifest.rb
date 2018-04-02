ndbd_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kea-mysql-ndbd"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "ndbd",
        "image" => node['kube']['images']['mysql_cluster'],
        "args" => [
          "/ndbd-entrypoint",
          %Q{--ndb-connectstring=#{node['kube_manifests']['kea']['mysql_mgm_ips'].join(',')}}
        ],
        "volumeMounts" => [
          {
            "mountPath" => "/var/lib/mysql-cluster",
            "name" => "mysql-data"
          }
        ]
      }
    ],
    "volumes" => [
      {
        "name" => "mysql-data",
        "emptyDir" => {}
      }
    ]
  }
}

mysqld_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kea-mysql-mysqld"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "mysqld",
        "image" => node['kube']['images']['mysql_cluster'],
        "args" => [
          "/mysqld-entrypoint",
          "--ndbcluster",
          "--default_storage_engine=ndbcluster",
          "--bind-address=127.0.0.1",
          %Q{--ndb-connectstring=#{node['kube_manifests']['kea']['mysql_mgm_ips'].join(',')}}
        ],
        "env" => [
          {
            "name" => "INIT",
            "value" => [
              %Q{CREATE DATABASE IF NOT EXISTS #{node['kube_manifests']['kea']['mysql_database']};},
              %Q{CREATE USER IF NOT EXISTS '#{node['kube_manifests']['kea']['mysql_user']}'@'127.0.0.1';},
              %Q{GRANT ALL PRIVILEGES ON #{node['kube_manifests']['kea']['mysql_database']}.* TO '#{node['kube_manifests']['kea']['mysql_user']}'@'127.0.0.1' WITH GRANT OPTION;}
            ].join($/)
          }
        ]
      }
    ]
  }
}

kea_dns_port_internal = 53530

dnsdist_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kea-dnsdist"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "dnsdist",
        "image" => node['kube']['images']['dnsdist'],
        "args" => [
          "-v",
          "-l",
          "0.0.0.0:#{node['environment_v2']['port']['kea-dns']}",
        ] + node['environment_v2']['set']['kea']['hosts'].map { |e|
          "#{node['environment_v2']['host'][e]['ip']['store']}:#{kea_dns_port_internal}"
        }
      }
    ]
  }
}

tftp_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kea-tftp"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "tftpd-ipxe",
        "image" => node['kube']['images']['tftpd_ipxe'],
        "args" => [
          "--address",
          "0.0.0.0:69",
          "--verbose"
        ]
      }
    ]
  }
}


# kea nodes
node['environment_v2']['set']['kea']['hosts'].each do |host|

  nextserver = node['environment_v2']['host'][host]['ip']['store']

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
        "type" => "mysql",
        "name" => node['kube_manifests']['kea']['mysql_database'],
        "host" => "127.0.0.1",
        # "host" => "",
        # "port" => 3306,
        "user" => node['kube_manifests']['kea']['mysql_user'],
        # "password" => node['mysql_credentials']['kea']['password'],
        "password" => "",
        "persist" => true
      },
      "client-classes" => [
        {
          "name" => "ipxe_detected",
          "test" => "substring(option[77].hex,0,4) == 'iPXE'",
          "boot-file-name" => "http://#{node['environment_v2']['set']['haproxy']['vip']['store']}:#{node['environment_v2']['port']['matchbox-http']}/boot.ipxe"
        },
        {
          "name" => "ipxe",
          "test" => "not(substring(option[77].hex,0,4) == 'iPXE') and (option[93].hex == 0x0000)",
          "next-server" => nextserver,
          "boot-file-name" => "/undionly.kpxe"
        },
        {
          "name" => "ipxe_efi",
          "test" => "not(substring(option[77].hex,0,4) == 'iPXE') and (option[93].hex == 0x0007)",
          "next-server" => nextserver,
          "boot-file-name" => "/ipxe.efi"
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


  kea_manifest = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      "name" => "kea-mysql"
    },
    "spec" => {
      "restartPolicy" => "Always",
      "hostNetwork" => true,
      "initContainers" => [
        {
          "name" => "kea-mysql-seeder",
          "image" => node['kube']['images']['mysql_cluster'],
          "args" => [
            "/seeder",
            "--host=127.0.0.1",
            # "--socket=/var/run/mysqld/mysql.sock",
            "--user=#{node['kube_manifests']['kea']['mysql_user']}",
            # "--password=#{node['mysql_credentials']['kea']['password']}"
          ],
          "env" => [
            {
              "name" => "SQL",
              "value" => node['kube_manifests']['kea']['mysql_seed_sql']
            }
          ]
        }
      ],
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
          ]
        },
        {
          "name" => "kea-resolver",
          "image" =>node['kube']['images']['kea_resolver'],
          "args" => [
            "-h",
            "127.0.0.1",
            "-d",
            node['kube_manifests']['kea']['mysql_database'],
            "-u",
            node['kube_manifests']['kea']['mysql_user'],
            # "-w",
            # node['mysql_credentials']['kea']['password'],
            "-listen",
            "#{kea_dns_port_internal}"
          ]
        }
      ]
    }
  }


  node.default['kubernetes']['static_pods'][host]['kea-mysql'] = kea_manifest
  node.default['kubernetes']['static_pods'][host]['kea-tftp'] = tftp_manifest
  node.default['kubernetes']['static_pods'][host]['kea-dnsdist'] = dnsdist_manifest
end

# kea mysql-data
node['environment_v2']['set']['kea-mysql-data']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['kea-mysql-ndbd'] = ndbd_manifest
  node.default['kubernetes']['static_pods'][host]['kea-mysql-mysqld'] = mysqld_manifest
end

# kea mysql-mgm
node['environment_v2']['set']['kea-mysql-mgm']['hosts'].each.with_index(1) do |host, index|
  node.default['kubernetes']['static_pods'][host]['kea-mysql-ndb-mgmd'] = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      "name" => "kea-mysql-ndb-mgmd"
    },
    "spec" => {
      "restartPolicy" => "Always",
      "hostNetwork" => true,
      "containers" => [
        {
          "name" => "ndb-mgmd",
          "image" => node['kube']['images']['mysql_cluster'],
          "args" => [
            "/ndb_mgmd-entrypoint",
            "--ndb-nodeid=#{index}"
          ],
          "env" => [
            {
              "name" => "CONFIG",
              "value" => node['kube_manifests']['kea']['mysql_ndb_mgmd_config']
            }
          ]
        }
      ]
    }
  }
end
