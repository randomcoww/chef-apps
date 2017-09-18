master_hosts = node['environment_v2']['set']['kube-master']['hosts']

kube_proxy_manifest = {
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "kube-proxy",
    "namespace": "kube-system"
  },
  "spec": {
    "hostNetwork": true,
    "containers": [
      {
        "name": "kube-proxy",
        "image": node['kube']['images']['hyperkube'],
        "command": [
          "/hyperkube",
          "proxy",
          "--master=https://#{node['environment_v2']['set']['gateway']['vip_lan']}",
          "--kubeconfig=#{node['kubernetes']['kube_proxy']['kubeconfig_path']}"
        ],
        "securityContext": {
          "privileged": true
        },
        "volumeMounts": [
          {
            "name" => "srv-kubernetes",
            "mountPath" => node['kubernetes']['srv_path'],
            "readOnly" => true
          },
          {
            "name" => "kubeconfig",
            "mountPath" => node['kubernetes']['kube_proxy']['kubeconfig_path'],
            "readOnly" => true
          },
          {
            "mountPath": "/etc/ssl",
            "name": "ssl-certs-host",
            "readOnly": true
          }
        ]
      }
    ],
    "volumes": [
      {
        "name" => "srv-kubernetes",
        "hostPath" => {
          "path" => node['kubernetes']['srv_path']
        }
      },
      {
        "name" => "kubeconfig",
        "hostPath" => {
          "path" => node['kubernetes']['kube_proxy']['kubeconfig_path']
        }
      },
      {
        "name" => "ssl-certs-host",
        "hostPath" => {
          "path" => "/etc/ssl"
        }
      }
    ]
  }
}

node['kube_manifests']['kube_worker']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['kube-proxy_manifest.yaml'] = kube_proxy_manifest
end
