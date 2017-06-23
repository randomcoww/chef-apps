node.default['kube_static_pods'][node['hostname']]['kea.yaml'] = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kea-dhcp4"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "kea-dhcp4",
        "image" => node['kea']['docker_image'],
        "args" => [
          "kea-dhcp4"
        ],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => JSON.pretty_generate(node['kea']['dhcp4_mysql']['config'])
          }
        ]
      },
      {
        "name" => "kea-dhcp-ddns",
        "image" => node['kea']['docker_image'],
        "args" => [
          "kea-dhcp-ddns"
        ],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => JSON.pretty_generate(node['kea']['ddns']['config'])
          }
        ]
      }
    ]
  }
}
