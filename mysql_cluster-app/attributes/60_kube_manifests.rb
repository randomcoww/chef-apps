node.default['kubernetes']['static_pods']['mysql-cluster-ndb.yaml'] = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "mysql-cluster"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "mysqld",
        "image" => node['mysql_cluster']['docker_image'],
        "args" => [
          "--ndbcluster",
          "--default_storage_engine=ndbcluster",
          "--bind-address=0.0.0.0",
          "--ndb-connectstring=192.168.62.237"
        ],
        "env" => [
          {
            "name" => "INIT",
            "value" => "ALTER USER 'root'@'localhost' IDENTIFIED BY '#{node['mysql_credentials']['root']['password']}';"
          }
        ]
      },
      {
        "name" => "ndbd",
        "image" => node['mysql_cluster']['docker_image'],
        "args" => [
          "--ndb-connectstring=192.168.62.237"
        ]
      }
    ]
  }
}
