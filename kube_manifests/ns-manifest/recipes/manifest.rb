unbound_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "dns"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "unbound",
        "image" => node['kube']['images']['unbound'],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => node['kube_manifests']['ns']['unbound_config']
          }
        ]
      }
    ]
  }
}

node['environment_v2']['set']['ns']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['unbound'] = unbound_manifest
end
