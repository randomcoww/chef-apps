node.default['kubernetes']['static_pods']['kube-apiserver.yaml'] = {
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
        "image" => node['kubernetes']['hyperkube_image'],
        "command" => [
          "/hyperkube",
          "apiserver",
          "--bind-address=0.0.0.0",
          # "--bind-address=127.0.0.1",
          # "--address=127.0.0.1",
          "--secure-port=#{node['kubernetes']['secure_port']}",
          "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
          "--etcd-servers=#{node['kubernetes']['etcd']['nodes']}",
          "--tls-cert-file=#{node['kubernetes']['cert_path']}",
          "--tls-private-key-file=#{node['kubernetes']['key_path']}",
          "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds",
          "--client-ca-file=#{node['kubernetes']['ca_path']}",
          "--service-account-key-file=#{node['kubernetes']['key_path']}",
          # "--basic-auth-file=#{node['kubernetes']['basic_auth_path']}",
          # "--token-auth-file=#{node['kubernetes']['token_file_path']}",
          # "--allow-privileged=true"
        ],
        "ports" => [
          {
            "name" => "https",
            "hostPort" => node['kubernetes']['secure_port'],
            "containerPort" => node['kubernetes']['secure_port']
          },
          {
            "name" => "local",
            "hostPort" => node['kubernetes']['insecure_port'],
            "containerPort" => node['kubernetes']['insecure_port']
          }
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

node.default['kubernetes']['static_pods']['kube-controller-manager.yaml'] = {
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
        "image" => node['kubernetes']['hyperkube_image'],
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

node.default['kubernetes']['static_pods']['kube-scheduler.yaml'] = {
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
        "image" => node['kubernetes']['hyperkube_image'],
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

node.default['kubernetes']['static_pods']['kube-addon-manager.yaml'] = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kube-addon-manager",
    "namespace" => "kube-system",
    "labels" => {
      "component" => "kube-addon-manager"
    }
  },
  "spec" => {
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "kube-addon-manager",
        "image" => "gcr.io/google-containers/kube-addon-manager:v6.1",
        "command" => [
          "/bin/bash",
          "-c",
          "/opt/kube-addons.sh"
        ],
        "resources" => {
          "requests" => {
            "cpu" => "5m",
            "memory" => "50Mi"
          }
        },
        "volumeMounts" => [
          {
            "mountPath" => node['kubernetes']['addons_path'],
            "name" => "addons",
            "readOnly" => true
          }
        ]
      }
    ],
    "volumes" => [
      {
        "hostPath" => {
          "path" => node['kubernetes']['addons_path']
        },
        "name" => "addons"
      }
    ]
  }
}

# node.default['kubernetes']['static_pods']['kubernetes-dashboard.yaml'] = {
#   "apiVersion" => "v1",
#   "kind" => "Pod",
#   "metadata" => {
#     "name" => "kubernetes-dashboard",
#     "namespace" => "kube-system",
#     "labels" => {
#       "k8s-app" => "kubernetes-dashboard"
#     }
#   },
#   "spec" => {
#     "hostNetwork" => true,
#     "containers" => [
#       {
#         "name" => "kubernetes-dashboard",
#         "image" => "gcr.io/google_containers/kubernetes-dashboard-amd64:v1.6.1",
#         "command" => [
#           "/dashboard",
#           "--bind-address=0.0.0.0",
#           "--insecure-bind-address=0.0.0.0",
#           "--port=8443",
#           "--apiserver-host=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
#           "--tls-cert-file=#{node['kubernetes']['cert_path']}",
#           "--tls-key-file=#{node['kubernetes']['key_path']}"
#         ],
#         "volumeMounts" => [
#           {
#             "name" => "srv-kubernetes",
#             "mountPath" => node['kubernetes']['srv_path'],
#             "readOnly" => true
#           },
#           {
#             "name" => "ssl-certs-host",
#             "mountPath" => "/etc/ssl",
#             "readOnly" => true
#           }
#         ],
#         "livenessProbe" => {
#           "httpGet" => {
#             "path" => "/",
#             "port" => 9090
#           },
#           "initialDelaySeconds" => 30,
#           "timeoutSeconds" => 30
#         }
#       }
#     ],
#     "volumes" => [
#       {
#         "name" => "srv-kubernetes",
#         "hostPath" => {
#           "path" => node['kubernetes']['srv_path'],
#         }
#       },
#       {
#         "name" => "ssl-certs-host",
#         "hostPath" => {
#           "path" => "/etc/ssl"
#         }
#       }
#     ]
#   }
# }
