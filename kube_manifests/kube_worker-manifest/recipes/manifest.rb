env_vars = node['environment_v2']['set']['kube-master']['vars']
master_hosts = node['environment_v2']['set']['kube-master']['hosts']


flannel_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kube-flannel",
    # "namespace" => "kube-system",
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
          "--kubeconfig-file=#{::File.join(node['kubernetes']['kubernetes_path'], "kube-flannel.kubeconfig")}"
        ],
        "securityContext" => {
          "capabilities" => {
            "add" => [
              "NET_ADMIN"
            ]
          }
        },
        "volumeMounts" => [
          {
            "name" => "kubeconfig",
            "mountPath" => node['kubernetes']['client']['kubeconfig_path'],
            "readOnly" => true
          }
        ]
      }
    ],
    "volumes" => [
      {
        "name" => "kubeconfig",
        "hostPath" => {
          "path" => node['kubernetes']['client']['kubeconfig_path']
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
    # "namespace": "kube-system"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "kube-proxy",
        "image" => node['kube']['images']['hyperkube'],
        "command" => [
          "/hyperkube",
          "proxy",
          "--config=#{::File.join(node['kubernetes']['kubernetes_path'], "kube-proxy-config.yaml")}"
        ],
        "securityContext" => {
          "capabilities" => {
            "add" => [
              "NET_ADMIN"
            ]
          }
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


kube_haproxy_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    # "namespace" => "kube-system",
    "name" => "kube-haproxy"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "kube-haproxy",
        "image" => node['kube']['images']['kube_haproxy'],
        "env" => [
          {
            "name" => "CONFIG",
            "value" => node['kube_manifests']['haproxy']['template']
          }
        ],
        "args" => [
          "-kubeconfig",
          ::File.join(node['kubernetes']['kubernetes_path'], "kube-haproxy.kubeconfig"),
          "-output",
          node['kube_manifests']['haproxy']['config_path'],
          "-pid",
          node['kube_manifests']['haproxy']['pid_path']
        ],
        "volumeMounts" => [
          {
            "name" => "haproxy-config",
            "mountPath" => ::File.dirname(node['kube_manifests']['haproxy']['config_path'])
          },
          {
            "name" => "haproxy-pid",
            "mountPath" => ::File.dirname(node['kube_manifests']['haproxy']['pid_path'])
          },
          {
            "name" => "kubeconfig",
            "mountPath" => node['kubernetes']['kubernetes_path'],
            "readOnly" => true
          }
        ]
      },
      {
        "name" => "haproxy",
        "image" => node['kube']['images']['haproxy'],
        "args" => [
          "haproxy",
          "-V",
          "-f",
          node['kube_manifests']['haproxy']['config_path'],
          "-p",
          node['kube_manifests']['haproxy']['pid_path'],
        ],
        "volumeMounts" => [
          {
            "name" => "haproxy-config",
            "mountPath" => ::File.dirname(node['kube_manifests']['haproxy']['config_path'])
          },
          {
            "name" => "haproxy-pid",
            "mountPath" => ::File.dirname(node['kube_manifests']['haproxy']['pid_path'])
          }
        ]
      }
    ],
    "volumes" => [
      {
        "name" => "haproxy-config",
        "emptyDir" => {}
      },
      {
        "name" => "haproxy-pid",
        "emptyDir" => {}
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


node['environment_v2']['set']['kube-worker']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['flannel'] = flannel_manifest
  node.default['kubernetes']['static_pods'][host]['kube-proxy_manifest'] = kube_proxy_manifest
  node.default['kubernetes']['static_pods'][host]['kube-haproxy_manifest'] = kube_haproxy_manifest
end
