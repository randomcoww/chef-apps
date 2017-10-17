kube_controller_manager_manifest = {
  "kind" => "Pod",
  "apiVersion" => "v1",
  "metadata" => {
    "namespace" => "kube-system",
    "name" => "kube-controller-manager"
  },
  "spec" => {
    "restartPolicy" => 'Always',
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "kube-controller-manager",
        "image" => node['kube']['images']['hyperkube'],
        "command" => [
          "/hyperkube",
          "controller-manager",
          "--cluster-name=#{node['kubernetes']['cluster_name']}",
          "--cluster-cidr=#{node['kubernetes']['cluster_cidr']}",
          "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
          "--service-account-private-key-file=#{node['kubernetes']['key_path']}",
          "--root-ca-file=#{node['kubernetes']['ca_path']}",
          "--leader-elect=true",
          "--master=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
        ],
        "volumeMounts" => [
          {
            "name" => "srv-kubernetes",
            "mountPath" => node['kubernetes']['srv_path'],
            "readOnly" => true
          },
          {
            "name" => "ssl-certs-host",
            "mountPath" => "/etc/ssl",
            "readOnly" => true
          }
        ],
        "livenessProbe" => {
          "httpGet" => {
            "scheme" => "HTTP",
            "host" => "127.0.0.1",
            "port" => 10252,
            "path" => "/healthz"
          },
          "initialDelaySeconds" => 15,
          "timeoutSeconds" => 15
        }
      }
    ],
    "volumes" => [
      {
        "name" => "srv-kubernetes",
        "hostPath" => {
          "path" => node['kubernetes']['srv_path'],
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

kube_scheduler_manifest = {
  "kind" => "Pod",
  "apiVersion" => "v1",
  "metadata" => {
    "namespace" => "kube-system",
    "name" => "kube-scheduler"
  },
  "spec" => {
    "restartPolicy" => 'Always',
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "kube-scheduler",
        "image" => node['kube']['images']['hyperkube'],
        "command" => [
          "/hyperkube",
          "scheduler",
          "--master=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
          "--leader-elect=true"
        ],
        "livenessProbe" => {
          "httpGet" => {
            "scheme" => "HTTP",
            "host" => "127.0.0.1",
            "port" => 10251,
            "path" => "/healthz"
          },
          "initialDelaySeconds" => 15,
          "timeoutSeconds" => 15
        }
      }
    ]
  }
}

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
          "--master=http://127.0.0.1:#{node['kubernetes']['insecure_port']}"
        ],
        "securityContext": {
          "privileged": true
        },
        "volumeMounts": [
          {
            "mountPath": "/etc/ssl/certs",
            "name": "ssl-certs-host",
            "readOnly": true
          }
        ]
      }
    ],
    "volumes": [
      {
        "name" => "ssl-certs-host",
        "hostPath" => {
          "path" => "/etc/ssl"
        }
      }
    ]
  }
}

kube_apiserver_manifest = {
  "kind" => "Pod",
  "apiVersion" => "v1",
  "metadata" => {
    "namespace" => "kube-system",
    "name" => "kube-apiserver"
  },
  "spec" => {
    "hostNetwork" => true,
    "restartPolicy" => 'Always',
    "containers" => [
      {
        "name" => "kube-apiserver",
        "image" => node['kube']['images']['hyperkube'],
        "command" => [
          "/hyperkube",
          "apiserver",
          "--bind-address=0.0.0.0",
          # "--bind-address=127.0.0.1",
          # "--address=127.0.0.1",
          "--secure-port=#{node['kubernetes']['secure_port']}",
          "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
          "--etcd-servers=http://#{node['environment_v2']['set']['haproxy']['vip_lan']}:#{node['environment_v2']['service']['etcd']['bind']}",
          "--tls-cert-file=#{node['kubernetes']['cert_path']}",
          "--tls-private-key-file=#{node['kubernetes']['key_path']}",
          "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds",
          "--client-ca-file=#{node['kubernetes']['ca_path']}",
          "--service-account-key-file=#{node['kubernetes']['key_path']}",
          # "--basic-auth-file=#{node['kubernetes']['basic_auth_path']}",
          # "--token-auth-file=#{node['kubernetes']['token_file_path']}",
          "--allow-privileged=true"
        ],
        "volumeMounts" => [
          {
            "name" => "srv-kubernetes",
            "mountPath" => node['kubernetes']['srv_path'],
            "readOnly" => true
          },
          {
            "name" => "ssl-certs-host",
            "mountPath" => "/etc/ssl",
            "readOnly" => true
          }
        ],
        "livenessProbe" => {
          "httpGet" => {
            "scheme" => "HTTP",
            "host" => "127.0.0.1",
            "port" => node['kubernetes']['insecure_port'],
            "path" => "/healthz"
          },
          "initialDelaySeconds" => 15,
          "timeoutSeconds" => 15
        }
      }
    ],
    "volumes" => [
      {
        "name" => "srv-kubernetes",
        "hostPath" => {
          "path" => node['kubernetes']['srv_path']
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

# kube_dashboard = {
#   "kind" => "Pod",
#   "apiVersion" => "v1",
#   "metadata" => {
#     "namespace" => "kube-system",
#     "name" => "kube-dashboard"
#   },
#   "spec" => {
#     "hostNetwork" => true,
#     "restartPolicy" => 'Always',
#     "containers" => [
#       {
#         "name" => "kube-dashboard",
#         "image" => node['kube']['images']['kube_dashboard'],
#         "args" => [
#           "--apiserver-host=http://127.0.0.1:8080"
#         ],
#         "volumeMounts" => [
#           {
#             "name" => "tmp-volume",
#             "mountPath" => "/tmp",
#           }
#         ],
#         "livenessProbe" => {
#           "httpGet" => {
#             "scheme" => "HTTP",
#             "port" => 9090,
#             "path" => "/"
#           },
#           "initialDelaySeconds" => 30,
#           "timeoutSeconds" => 30
#         }
#       }
#     ],
#     "volumes" => [
#       {
#         "name" => "tmp-volume",
#         "emptyDir" => {}
#       }
#     ]
#   }
# }

node['kube_manifests']['kube_master']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['kube-apiserver_manifest.yaml'] = kube_apiserver_manifest
  node.default['kubernetes']['static_pods'][host]['kube-controller-manager_manifest.yaml'] = kube_controller_manager_manifest
  node.default['kubernetes']['static_pods'][host]['kube-scheduler_manifest.yaml'] = kube_scheduler_manifest
  node.default['kubernetes']['static_pods'][host]['kube-proxy_manifest.yaml'] = kube_proxy_manifest
  # node.default['kubernetes']['static_pods'][host]['kube-dashboard.yaml'] = kube_dashboard
end
