node.default['kubelet']['static_pods']['dns.yaml'] = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "dns"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "containers" => [
      {
        "name" => "unbound",
        "image" => node['kube']['images']['unbound'],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => node['kubelet']['unbound']['config']
          }
        ],
        "ports" => [
          {
            "protocol" => "UDP",
            "containerPort" => 53,
            "hostPort" => 53,
          }
        ]
      },
      {
        "name" => "knot",
        "image" => node['kube']['images']['knot'],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => node['kubelet']['knot']['config']
          },
          {
            "name" => "ZONE_ST_LAN",
            "value" => node['kubelet']['knot']['static_zone']
          }
        ]
      },
      {
        "name" => "openvpn",
        "image" => node['kube']['images']['openvpn'],
        "securityContext" => {
          "capabilities" => {
            "add" => [
              "NET_ADMIN"
            ]
          }
        },
        "args" => [
          "--route 10.0.0.0 255.0.0.0 net_gateway",
          "--route 172.16.0.0 255.240.0.0 net_gateway",
          "--route 192.168.0.0 255.255.0.0 net_gateway",
          # "--route 169.254.0.0 255.255.0.0 net_gateway"
        ],
        "env" => [
          {
            "name" => "OVPN_CONFIG",
            "value" => node['kubelet']['openvpn']['config']
          },
          {
            "name" => "OVPN_AUTH_USER_PASS",
            "value" => node['kubelet']['openvpn']['auth_user_pass']
          },
          {
            "name" => "OVPN_CA",
            "value" => node['kubelet']['openvpn']['ca']
          }
        ],
        "volumeMounts" => [
          {
            "mountPath" => '/dev/net/tun',
            "name" => "nettun"
          }
        ]
      }
    ],
    "volumes" => [
      {
        "name" => "nettun",
        "hostPath" => {
          "path" => '/dev/net/tun'
        }
      }
    ]
  }
}

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
