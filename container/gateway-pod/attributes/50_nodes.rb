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
