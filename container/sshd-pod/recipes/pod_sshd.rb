include_recipe "sshd-pod::_sshd"

node.default['kubelet']['static_pods']['sshd.yaml'] = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "sshd"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "sshd",
        "image" => node['kube']['images']['sshd'],
        "args" => [
          "-p",
          "2222"
        ],
        "env" => [
          {
            "name" => "AUTHORIZED_KEYS",
            "value" => node['kubelet']['sshd']['authorized_keys'].join($/)
          },
          {
            "name" => "LOGIN",
            "value" => node['kubelet']['sshd']['login']
          }
        ],
        # "ports" => [
        #   {
        #     "protocol" => "TCP",
        #     "containerPort" => 22,
        #     "hostPort" => 2222,
        #   }
        # ]
      }
    ]
  }
}
