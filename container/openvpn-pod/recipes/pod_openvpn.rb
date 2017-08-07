include_recipe "openvpn-pod::_openvpn"


node.default['kubelet']['static_pods']['openvpn.yaml'] = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "openvpn"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
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
        # "args" => [
        #   "--route 192.168.0.0 255.255.0.0 net_gateway",
        # ],
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
