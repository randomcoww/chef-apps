haproxy_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "haproxy"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "haproxy",
        "image" => node['kube']['images']['haproxy'],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => node['kube_manifests']['gateway']['haproxy_config']
          }
        ]
      }
    ]
  }
}


node['environment_v2']['set']['haproxy']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['haproxy_manifest.yaml'] = haproxy_manifest
  # node.default['kubernetes']['static_pods'][host]['kube_apiserver_manifest.yaml'] = kube_apiserver_manifest
end
