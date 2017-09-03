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
        "image" => node['kube']['images']['mysql_cluster_ndbd'],
        "args" => [
          %Q{--ndb-connectstring=#{node['kube_manifests']['kea']['host_ips'].join(',')}}
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
        "image" => node['kube']['images']['mysql_cluster_mysqld'],
        "args" => [
          "--ndbcluster",
          "--default_storage_engine=ndbcluster",
          "--bind-address=0.0.0.0",
          %Q{--ndb-connectstring=#{node['kube_manifests']['kea']['host_ips'].join(',')}}
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
        "image" => node['kube']['images']['mysql_cluster_seeder'],
        "args" => [
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
      # {
      #   "name" => "kea-dhcp-ddns",
      #   "image" => node['kube']['images']['kea_dhcp_ddns'],
      #   "args" => [
      #     "kea-dhcp-ddns"
      #   ],
      #   "env" => [
      #     {
      #       "name" => "CONFIG",
      #       "value" => JSON.pretty_generate(node['kubelet']['ddns']['config'])
      #     }
      #   ]
      # }
    ]
  }
}


node['kube_manifests']['kea']['hosts'].each.with_index(1) do |host, index|

  node.default['kubernetes']['static_pods'][host]['kea-mysql-ndb-mgmd.yaml'] = {
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
          "image" => node['kube']['images']['mysql_cluster_ndb_mgmd'],
          "args" => [
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

  node.default['kubernetes']['static_pods'][host]['kea-mysql-ndbd.yaml'] = ndbd_manifest
  node.default['kubernetes']['static_pods'][host]['kea-mysql-mysqld.yaml'] = mysqld_manifest
  node.default['kubernetes']['static_pods'][host]['kea-mysql.yaml'] = kea_manifest
end
