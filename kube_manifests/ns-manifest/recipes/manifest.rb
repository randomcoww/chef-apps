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
        ],
        # "ports" => [
        #   {
        #     "containerPort" => 53,
        #     "hostPort" => 53,
        #     "protocol" => "TCP"
        #   },
        #   {
        #     "containerPort" => 53,
        #     "hostPort" => 53,
        #     "protocol" => "UDP"
        #   }
        # ]
      },
      {
        "name" => "dnsdist",
        "image" => node['kube']['images']['dnsdist'],
        "args" => [
          "-v",
          "-l",
          "0.0.0.0:53",
        ] + node['environment_v2']['set']['dns']['hosts'].map { |e|
          "#{node['environment_v2']['host'][e]['ip']['store']}:53532"
        }
      }
    ]
  }
}

node['environment_v2']['set']['dns']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['unbound'] = unbound_manifest
end
