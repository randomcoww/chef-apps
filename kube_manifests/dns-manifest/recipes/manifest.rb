dns_manifest = {
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
            "value" => node['kube_manifests']['dns']['unbound_config']
          }
        ]
      },
      # {
      #   "name" => "knot",
      #   "image" => node['kube']['images']['knot'],
      #   "env" => [
      #     {
      #       "name" => "CONFIG",
      #       "value" => node['kube_manifests']['dns']['knot_config']
      #     },
      #     {
      #       "name" => "ZONE_#{node['environment_v2']['domain']['top'].gsub('.', '_').upcase}",
      #       "value" => node['kube_manifests']['dns']['knot_static_zone']
      #     }
      #   ]
      # }
    ]
  }
}

node['kube_manifests']['dns']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['dns.yaml'] = dns_manifest
end
