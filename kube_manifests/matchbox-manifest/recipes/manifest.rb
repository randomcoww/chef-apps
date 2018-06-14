env_vars = node['environment_v2']['set']['matchbox']['vars']
ca_base = ::File.join(env_vars["ssl_path"], "ca")
ssl_base = ::File.join(env_vars["ssl_path"], "matchbox")

matchbox_manifest = {
  "kind" => "Pod",
  "apiVersion" => "v1",
  "metadata" => {
    "name" => "matchbox"
  },
  "spec" => {
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "matchbox",
        "image" => node['kube']['images']['matchbox'],
        "args" => [
          "-address=0.0.0.0:#{node['environment_v2']['port']['matchbox-http-internal']}",
          "-rpc-address=0.0.0.0:#{node['environment_v2']['port']['matchbox-rpc-internal']}",
          "-ca-file=#{ca_base}.pem",
          "-cert-file=#{ssl_base}.pem",
          "-key-file=#{ssl_base}-key.pem",
          "-data-path=#{env_vars["data_path"]}",
          "-assets-path=#{env_vars["assets_path"]}",
        ],
        "volumeMounts" => [
          {
            "mountPath" => env_vars["ssl_path"],
            "name" => "ssl-matchbox",
            "readOnly" => false
          },
          {
            "mountPath" => env_vars["data_path"],
            "name" => "data-matchbox",
            "readOnly" => false
          }
        ]
      }
    ],
    "volumes" => [
      {
        "name" => "ssl-matchbox",
        "hostPath" => {
          "path" => env_vars["ssl_path"]
        }
      },
      {
        "name" => "data-matchbox",
        "nfs" => {
          "server" => node['environment_v2']['set']['nfs']['vip']['store'],
          "path" => env_vars["mount_path"]
        }
      }
    ]
  }
}

node['environment_v2']['set']['matchbox']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['matchbox'] = matchbox_manifest
end
