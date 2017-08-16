include_recipe "dns-pod::_knot"
include_recipe "dns-pod::_knot_static_zone"
include_recipe "dns-pod::_unbound"
include_recipe "dns-pod::_openvpn"


node.default['kubelet']['static_pods']['dns.yaml'] = {
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
            "value" => node['kubelet']['unbound']['config']
          }
        ],
        # "ports" => [
        #   {
        #     "protocol" => "UDP",
        #     "containerPort" => 53,
        #     "hostPort" => 53,
        #   }
        # ]
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
            "name" => "ZONE_#{node['kubelet']['knot']['domain'].gsub('.', '_').upcase}",
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
        # "args" => [
        #   "--route 192.168.0.0 255.255.0.0 net_gateway",
        # ],
        "env" => [
          {
            "name" => "OVPN_CONFIG",
            "value" => node['kubelet']['openvpn_dns']['config']
          },
          {
            "name" => "OVPN_AUTH_USER_PASS",
            "value" => node['kubelet']['openvpn_dns']['auth_user_pass']
          },
          {
            "name" => "OVPN_CA",
            "value" => node['kubelet']['openvpn_dns']['ca']
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
