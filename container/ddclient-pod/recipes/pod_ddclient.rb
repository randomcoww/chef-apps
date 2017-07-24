include_recipe "ddclient-pod::_ddclient"

node.default['kubelet']['static_pods']['ddclient.yaml'] = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "ddclient"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "ddclient",
        "image" => node['kube']['images']['ddclient'],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => node['kubelet']['ddclient']['config']
          }
        ]
      }
    ]
  }
}
