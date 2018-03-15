cfssl_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "cfssl"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "cfssl",
        "image" => node['kube']['images']['cfssl'],
        "args" => [
          "serve",
          "-address",
          "0.0.0.0",
          "-ca",
          "/certs/root_ca/root_ca.pem",
          "-ca-key",
          "/certs/root_ca/root_ca-key.pem",
          "-config",
          "/certs/config.json",
        ],
        "volumeMounts" => [
          {
            "name" => "certs",
            "mountPath" => "/certs"
          }
        ],
        # "ports" => [
        #   {
        #     "containerPort" => 8888,
        #     "hostPort" => 8888,
        #     "protocol" => "TCP"
        #   }
        # ]
      }
    ],
    "volumes" => [
      {
        "name" => "certs",
        "hostPath" => {
          "path" => "/data/certs"
        }
      }
    ]
  }
}

node['environment_v2']['set']['ca']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['cfssl'] = cfssl_manifest
end
