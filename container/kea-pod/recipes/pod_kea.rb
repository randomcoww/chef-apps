# include_recipe "kea-pod::_mysql_packages"
# include_recipe "kea-pod::_mysql_seed"
include_recipe "kea-pod::_mysql"

include_recipe "kea-pod::_kea_dhcp4"
include_recipe "kea-pod::_kea_dhcp_ddns"


node.default['kubelet']['static_pods']['kea-mysql-mgmd.yaml'] = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kea-mysql-mgmd"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "ndb-mgmd",
        "image" => node['kube']['images']['mysql_cluster_ndb_mgmd'],
        "args" => [
          "--ndb-nodeid=#{node['kubelet']['nodeid']}"
        ],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => node['kubelet']['mysql_ndb_mgmd']['config']
          }
        ]
      }
    ]
  }
}

node.default['kubelet']['static_pods']['kea-mysql-ndbd.yaml'] = {
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
          %Q{--ndb-connectstring=#{node['environment_v2']['set']['kea-mysql-mgmd']['hosts'].map { |e|
              node['environment_v2']['host'][e]['ip_lan']
            }.join(',')}}
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

node.default['kubelet']['static_pods']['kea-mysql-mysqld.yaml'] = {
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
          %Q{--ndb-connectstring=#{node['environment_v2']['set']['kea-mysql-mgmd']['hosts'].map { |e|
              node['environment_v2']['host'][e]['ip_lan']
            }.join(',')}}
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

node.default['kubelet']['static_pods']['kea-mysql.yaml'] = {
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
            "value" => node['kubelet']['dhcp4_mysql']['sql']
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
            "value" => JSON.pretty_generate(node['kubelet']['dhcp4_mysql']['config'])
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
