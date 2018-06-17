flannel_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kube-flannel",
    "namespace" => "kube-system",
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "kube-flannel",
        "image" => node['kube']['images']['flannel'],
        "command" => [
          "/opt/bin/flanneld",
          "--ip-masq",
          "--kube-subnet-mgr",
          "--kubeconfig-file=#{::File.join(node['kubernetes']['kubernetes_path'], "kubelet.kubeconfig")}"
        ],
        "securityContext" => {
          "privileged" => true
        },
        "env" => [
          {
            "name" => "POD_NAME",
            "valueFrom" => {
              "fieldRef" => {
                "fieldPath" => "metadata.name"
              }
            }
          },
          {
            "name" => "POD_NAMESPACE",
            "valueFrom" => {
              "fieldRef" => {
                "fieldPath" => "metadata.namespace"
              }
            }
          }
        ],
        "volumeMounts" => [
          {
            "name" => "run",
            "mountPath" => "/run",
          },
          {
            "name" => "flannel-cfg",
            "mountPath" => "/etc/kube-flannel",
          },
          {
            "name" => "kubeconfig",
            "mountPath" => node['kubernetes']['kubernetes_path'],
            "readOnly" => true
          }
        ]
      }
    ],
    "volumes" => [
      {
        "name" => "run",
        "hostPath" => {
          "path" => "/run"
        }
      },
      {
        "name" => "flannel-cfg",
        "hostPath" => {
          "path" => "/etc/kube-flannel"
        }
      },
      {
        "name" => "kubeconfig",
        "hostPath" => {
          "path" => node['kubernetes']['kubernetes_path']
        }
      }
    ]
  }
}


kube_proxy_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kube-proxy",
    "namespace": "kube-system"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "kube-proxy",
        "image" => node['kube']['images']['kube-proxy'],
        "command" => [
          "kube-proxy",
          "--config=#{::File.join(node['kubernetes']['kubernetes_path'], "kube-proxy-config.yaml")}"
        ],
        "securityContext" => {
          "privileged" => true
        },
        "volumeMounts" => [
          {
            "name" => "kubeconfig",
            "mountPath" => node['kubernetes']['kubernetes_path'],
            "readOnly" => true
          }
        ]
      }
    ],
    "volumes" => [
      {
        "name" => "kubeconfig",
        "hostPath" => {
          "path" => node['kubernetes']['kubernetes_path']
        }
      }
    ]
  }
}


node['environment_v2']['set']['kube-worker']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['flannel'] = flannel_manifest
  node.default['kubernetes']['static_pods'][host]['kube-proxy_manifest'] = kube_proxy_manifest
end
