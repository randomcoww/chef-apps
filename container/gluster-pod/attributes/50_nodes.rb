node.default['kubelet']['static_pods']['keepalived.yaml'] = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "keepalived"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "keepalived",
        "image" => node['kube']['images']['keepalived'],
        "securityContext" => {
          "capabilities" => {
            "add" => [
              "NET_ADMIN"
            ]
          }
        },
        "env" => [
          {
            "name" => "CONFIG",
            "value" => node['kubelet']['keepalived']['config']
          }
        ]
      }
    ]
  }
}
