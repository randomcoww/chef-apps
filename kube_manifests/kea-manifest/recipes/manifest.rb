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
          "--bind-address=0.0.0.0",
          %Q{--ndb-connectstring=#{node['kube_manifests']['kea']['mysql_mgm_ips'].join(',')}}
        ],
        "env" => [
          {
            "name" => "INIT",
            "value" => [
              %Q{CREATE DATABASE IF NOT EXISTS #{node['mysql_credentials']['kea']['database']};},
              %Q{CREATE USER IF NOT EXISTS '#{node['mysql_credentials']['kea']['username']}'@'%' IDENTIFIED BY '#{node['mysql_credentials']['kea']['password']}';},
              %Q{GRANT ALL PRIVILEGES ON #{node['mysql_credentials']['kea']['database']}.* TO '#{node['mysql_credentials']['kea']['username']}'@'%' WITH GRANT OPTION;}
            ].join($/)
          }
        ]
      }
    ]
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
          "--user=#{node['mysql_credentials']['kea']['username']}",
          "--password=#{node['mysql_credentials']['kea']['password']}"
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
            "value" => JSON.pretty_generate(node['kube_manifests']['kea']['dhcp4_config'])
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
          node['mysql_credentials']['kea']['database'],
          "-u",
          node['mysql_credentials']['kea']['username'],
          "-w",
          node['mysql_credentials']['kea']['password'],
          "-listen",
          "53530"
        ]
      },
      {
        "name" => "dnsdist",
        "image" => node['kube']['images']['dnsdist'],
        "args" => [
          "-v",
          "-l",
          "0.0.0.0:53531",
        ] + node['environment_v2']['set']['kea']['hosts'].map { |e|
          "#{node['environment_v2']['host'][e]['ip']['store']}:53530"
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
  node.default['kubernetes']['static_pods'][host]['kea-mysql'] = kea_manifest
end

# kea mysql-data
node['environment_v2']['set']['kea-mysql-data']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['kea-mysql-ndbd'] = ndbd_manifest
  node.default['kubernetes']['static_pods'][host]['kea-mysql-mysqld'] = mysqld_manifest
end

# tftp
node['environment_v2']['set']['pxe']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['tftp'] = tftp_manifest
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
