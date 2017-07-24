include_recipe "haproxy-pod::_haproxy"

node.default['kubelet']['static_pods']['haproxy.yaml'] = {
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
            "value" => node['kubelet']['haproxy']['config']
          }
        ]
      }
    ]
  }
}
