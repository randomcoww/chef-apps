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
            "value" => node['kube_manifests']['dns']['knot_config']
          },
          {
            "name" => "ZONE_#{node['environment_v2']['domain']['top'].gsub('.', '_').upcase}",
            "value" => node['kube_manifests']['dns']['knot_static_zone']
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
            "value" => node['kube_manifests']['dns']['openvpn_config']
          },
          {
            "name" => "OVPN_AUTH_USER_PASS",
            "value" => node['kube_manifests']['dns']['openvpn_auth_user_pass']
          },
          {
            "name" => "OVPN_CA",
            "value" => node['kube_manifests']['dns']['openvpn_ca']
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

node['kube_manifests']['dns']['hosts'].each.with_index(1) do |host, index|
  node.default['kubernetes']['static_pods'][host]['dns.yaml'] = dns_manifest
end
