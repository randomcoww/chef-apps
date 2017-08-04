node.default['kubernetes']['static_pods']['etcd.yaml'] = {
  "kind" => "Pod",
  "apiVersion" => "v1",
  "metadata" => {
    "namespace" => "kube-system",
    "name" => "etcd"
  },
  "spec" => {
    "hostNetwork" => true,
    "restartPolicy" => 'Always',
    "containers" => [
      {
        "name" => "kube-etcd",
        "image" => "quay.io/coreos/etcd:latest",
        "command" => [
          "/usr/local/bin/etcd",
          "--data-dir=/var/lib/etcd"
        ],
        "env" => node['kubernetes']['etcd']['environment'].map { |k, v|
          {
            "name" => k,
            "value" => v
          }
        },
        "volumeMounts" => [
          {
            "mountPath" => "/var/lib/etcd",
            "name" => "etcd-data"
          }
        ]
      }
    ],
    "volumes" => [
      {
        "name" => "etcd-data",
        "emptyDir" => {}
      }
    ]
  }
}


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
          "--etcd-servers=http://127.0.0.1:2379",
          "--tls-cert-file=#{node['kubernetes']['cert_path']}",
          "--tls-private-key-file=#{node['kubernetes']['key_path']}",
          "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds",
          "--client-ca-file=#{node['kubernetes']['ca_path']}",
          "--service-account-key-file=#{node['kubernetes']['key_path']}",
          # "--basic-auth-file=#{node['kubernetes']['basic_auth_path']}",
          # "--token-auth-file=#{node['kubernetes']['token_file_path']}",
          "--allow-privileged=true"
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

# node.default['kubernetes']['static_pods']['kube-addon-manager.yaml'] = {
#   "apiVersion" => "v1",
#   "kind" => "Pod",
#   "metadata" => {
#     "name" => "kube-addon-manager",
#     "namespace" => "kube-system",
#     "labels" => {
#       "component" => "kube-addon-manager"
#     }
#   },
#   "spec" => {
#     "hostNetwork" => true,
#     "containers" => [
#       {
#         "name" => "kube-addon-manager",
#         "image" => "gcr.io/google-containers/kube-addon-manager:v6.1",
#         "command" => [
#           "/bin/bash",
#           "-c",
#           "/opt/kube-addons.sh"
#         ],
#         "resources" => {
#           "requests" => {
#             "cpu" => "5m",
#             "memory" => "50Mi"
#           }
#         },
#         "volumeMounts" => [
#           {
#             "mountPath" => node['kubernetes']['addons_path'],
#             "name" => "addons",
#             "readOnly" => true
#           }
#         ]
#       }
#     ],
#     "volumes" => [
#       {
#         "hostPath" => {
#           "path" => node['kubernetes']['addons_path']
#         },
#         "name" => "addons"
#       }
#     ]
#   }
# }

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


# node.default['kubelet']['static_pods']['kube-apiserver.yaml'] = {
#   "kind" => "Pod",
#   "apiVersion" => "v1",
#   "metadata" => {
#     "namespace" => "kube-system",
#     "name" => "kube-apiserver"
#   },
#   "spec" => {
#     # "hostNetwork" => true,
#     "restartPolicy" => 'Always',
#     "containers" => [
#       {
#         "name" => "kube-etcd",
#         "image" => "quay.io/coreos/etcd:latest",
#         "command" => [
#           "/usr/local/bin/etcd",
#           "--name",
#           "etcd0",
#           "--data-dir=/var/lib/etcd",
#           "--advertise-client-urls",
#           "http://127.0.0.1:2379",
#           "--listen-client-urls",
#           "http://0.0.0.0:2379",
#           "--initial-advertise-peer-urls",
#           "http://127.0.0.1:2380",
#           "--listen-peer-urls",
#           "http://0.0.0.0:2380",
#           "--initial-cluster-token",
#           "etcd-cluster-1",
#           "--initial-cluster",
#           "etcd0=http://127.0.0.1:2380",
#           "--initial-cluster-state",
#           "new"
#         ],
#         "volumeMounts" => [
#           {
#             "mountPath" => "/var/lib/etcd",
#             "name" => "etcd-data"
#           }
#         ]
#       },
#       {
#         "name" => "kube-apiserver",
#         "image" => node['kubernetes']['hyperkube_image'],
#         "command" => [
#           "/hyperkube",
#           "apiserver",
#           "--bind-address=0.0.0.0",
#           "--insecure-bind-address=0.0.0.0",
#           "--secure-port=#{node['kubernetes']['secure_port']}",
#           "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
#           "--etcd-servers=http://127.0.0.1:2379",
#           # "--tls-cert-file=#{node['kubernetes']['cert_path']}",
#           # "--tls-private-key-file=#{node['kubernetes']['key_path']}",
#           # "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds",
#           "--admission-control=",
#           # "--service-account-key-file=#{node['kubernetes']['key_path']}",
#           "--allow-privileged=true"
#         ],
#         "volumeMounts" => [
#           {
#             "name" => "srv-kubernetes",
#             "mountPath" => node['kubernetes']['srv_path'],
#             "readOnly" => true
#           }
#         ],
#         "ports" => [
#           {
#             "protocol" => "TCP",
#             "containerPort" => 8080,
#             "hostPort" => 8080,
#           },
#           {
#             "protocol" => "TCP",
#             "containerPort" => 8443,
#             "hostPort" => 8443,
#           }
#         ],
#         "livenessProbe" => {
#           "httpGet" => {
#             "scheme" => "HTTP",
#             "host" => "127.0.0.1",
#             "port" => node['kubernetes']['insecure_port'],
#             "path" => "/healthz"
#           },
#           "initialDelaySeconds" => 15,
#           "timeoutSeconds" => 15
#         }
#       },
#       {
#         "name" => "kube-controller-manager",
#         "image" => node['kubernetes']['hyperkube_image'],
#         "command" => [
#           "/hyperkube",
#           "controller-manager",
#           "--cluster-name=#{node['kubernetes']['cluster_name']}",
#           "--cluster-cidr=#{node['kubernetes']['cluster_cidr']}",
#           "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
#           # "--service-account-private-key-file=#{node['kubernetes']['key_path']}",
#           # "--root-ca-file=#{node['kubernetes']['ca_path']}",
#           "--leader-elect=true",
#           "--master=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
#         ],
#         "volumeMounts" => [
#           {
#             "name" => "srv-kubernetes",
#             "mountPath" => node['kubernetes']['srv_path'],
#             "readOnly" => true
#           }
#         ],
#         "livenessProbe" => {
#           "httpGet" => {
#             "scheme" => "HTTP",
#             "host" => "127.0.0.1",
#             "port" => 10252,
#             "path" => "/healthz"
#           },
#           "initialDelaySeconds" => 15,
#           "timeoutSeconds" => 15
#         }
#       },
#       {
#         "name" => "kube-scheduler",
#         "image" => node['kubernetes']['hyperkube_image'],
#         "command" => [
#           "/hyperkube",
#           "scheduler",
#           "--master=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
#           "--leader-elect=true"
#         ],
#         "livenessProbe" => {
#           "httpGet" => {
#             "scheme" => "HTTP",
#             "host" => "127.0.0.1",
#             "port" => 10251,
#             "path" => "/healthz"
#           },
#           "initialDelaySeconds" => 15,
#           "timeoutSeconds" => 15
#         }
#       },
#       {
#         "name" => "kubernetes-dashboard",
#         "image" => "gcr.io/google_containers/kubernetes-dashboard-amd64:v1.6.1",
#         "command" => [
#           "/dashboard",
#           "--bind-address=0.0.0.0",
#           "--insecure-bind-address=0.0.0.0",
#           "--port=8443",
#           "--apiserver-host=http://127.0.0.1:#{node['kubernetes']['insecure_port']}"
#         ],
#         "ports" => [
#           {
#             "protocol" => "TCP",
#             "containerPort" => 9090,
#             "hostPort" => 9090,
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
#         "name" => "etcd-data",
#         "emptyDir" => {}
#       }
#     ]
#   }
# }


# node.default['kubelet']['static_pods']['kubernetes-dns.yaml'] = {
#   "apiVersion" => "v1",
#   "kind" => "Pod",
#   "metadata" => {
#     "name" => "kubernetes-dns",
#     "namespace" => "kube-system",
#     "labels" => {
#       "k8s-app" => "kubernetes-dns"
#     }
#   },
#   "spec" => {
#     "hostNetwork" => true,
#     "containers" => [
#       {
#         "name" => "kubedns",
#         "image" => "gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.2",
#         "resources" => {
#           "limits" => {
#             "memory" => "170Mi"
#           },
#           "requests" => {
#             "cpu" => "100m",
#             "memory" => "70Mi"
#           }
#         },
#         "livenessProbe" => {
#           "httpGet" => {
#             "path" => "/healthcheck/kubedns",
#             "port" => 10054,
#             "scheme" => "HTTP"
#           },
#           "initialDelaySeconds" => 60,
#           "timeoutSeconds" => 5,
#           "successThreshold" => 1,
#           "failureThreshold" => 5
#         },
#         "readinessProbe" => {
#           "httpGet" => {
#             "path" => "/readiness",
#             "port" => 8081,
#             "scheme" => "HTTP"
#           },
#           "initialDelaySeconds" => 3,
#           "timeoutSeconds" => 5
#         },
#         "args" => [
#           "--domain=#{node['kubernetes']['cluster_domain']}.",
#           "--dns-port=10053",
#           "--config-dir=/kube-dns-config",
#           "--nameservers=#{node['environment_v2']['set']['dns']['vip_lan']}",
#           "--kube-master-url=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
#           "--v=2"
#         ],
#         "env" => [
#           {
#             "name" => "PROMETHEUS_PORT",
#             "value" => "10055"
#           }
#         ],
#         "ports" => [
#           {
#             "containerPort" => 10053,
#             "name" => "dns-local",
#             "protocol" => "UDP"
#           },
#           {
#             "containerPort" => 10053,
#             "name" => "dns-tcp-local",
#             "protocol" => "TCP"
#           },
#           {
#             "containerPort" => 10055,
#             "name" => "metrics",
#             "protocol" => "TCP"
#           }
#         ],
#         "volumeMounts" => [
#           {
#             "name" => "kube-dns-config",
#             "mountPath" => "/kube-dns-config"
#           }
#         ]
#       },
#       {
#         "name" => "dnsmasq",
#         "image" => "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.2",
#         "livenessProbe" => {
#           "httpGet" => {
#             "path" => "/healthcheck/dnsmasq",
#             "port" => 10054,
#             "scheme" => "HTTP"
#           },
#           "initialDelaySeconds" => 60,
#           "timeoutSeconds" => 5,
#           "successThreshold" => 1,
#           "failureThreshold" => 5
#         },
#         "args" => [
#           "-v=2",
#           "-logtostderr",
#           "-configDir=/etc/k8s/dns/dnsmasq-nanny",
#           "-restartDnsmasq=true",
#           "--",
#           "-k",
#           "--cache-size=1000",
#           "--log-facility=-",
#           "--server=/#{node['kubernetes']['cluster_domain']}/127.0.0.1#10053",
#           "--server=/in-addr.arpa/127.0.0.1#10053",
#           "--server=/ip6.arpa/127.0.0.1#10053"
#         ],
#         "ports" => [
#           {
#             "containerPort" => 53,
#             "name" => "dns",
#             "protocol" => "UDP"
#           },
#           {
#             "containerPort" => 53,
#             "name" => "dns-tcp",
#             "protocol" => "TCP"
#           }
#         ],
#         "resources" => {
#           "requests" => {
#             "cpu" => "150m",
#             "memory" => "20Mi"
#           }
#         },
#         "volumeMounts" => [
#           {
#             "name" => "kube-dns-config",
#             "mountPath" => "/etc/k8s/dns/dnsmasq-nanny"
#           }
#         ]
#       },
#       {
#         "name" => "sidecar",
#         "image" => "gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.2",
#         "livenessProbe" => {
#           "httpGet" => {
#             "path" => "/metrics",
#             "port" => 10054,
#             "scheme" => "HTTP"
#           },
#           "initialDelaySeconds" => 60,
#           "timeoutSeconds" => 5,
#           "successThreshold" => 1,
#           "failureThreshold" => 5
#         },
#         "args" => [
#           "--v=2",
#           "--logtostderr",
#           "--probe=kubedns,127.0.0.1:10053,kubernetes.default.svc.#{node['kubernetes']['cluster_domain']},5,A",
#           "--probe=dnsmasq,127.0.0.1:53,kubernetes.default.svc.#{node['kubernetes']['cluster_domain']},5,A"
#         ],
#         "ports" => [
#           {
#             "containerPort" => 10054,
#             "name" => "metrics",
#             "protocol" => "TCP"
#           }
#         ],
#         "resources" => {
#           "requests" => {
#             "memory" => "20Mi",
#             "cpu" => "10m"
#           }
#         }
#       }
#     ],
#     "volumes" => [
#       {
#         "name" => "kube-dns-config",
#         "configMap" => {
#           "name" => "kube-dns",
#           "optional" => true
#         }
#       }
#     ]
#   }
# }

# node.default['kubelet']['static_pods']['kubernetes-dns.yaml'] = {
#   "apiVersion" => "v1",
#   "kind" => "Pod",
#   "metadata" => {
#     "name" => "kubernetes-dns",
#     "namespace" => "kube-system",
#     "labels" => {
#       "k8s-app" => "kubernetes-dns"
#     }
#   },
#   "spec" => {
#     "hostNetwork" => true,
#     "containers" => [
#       {
#         "name" => "kubedns",
#         "image" => "gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.2",
#         "resources" => {
#           "limits" => {
#             "memory" => "170Mi"
#           },
#           "requests" => {
#             "cpu" => "100m",
#             "memory" => "70Mi"
#           }
#         },
#         "livenessProbe" => {
#           "httpGet" => {
#             "path" => "/healthcheck/kubedns",
#             "port" => 10054,
#             "scheme" => "HTTP"
#           },
#           "initialDelaySeconds" => 60,
#           "timeoutSeconds" => 5,
#           "successThreshold" => 1,
#           "failureThreshold" => 5
#         },
#         "readinessProbe" => {
#           "httpGet" => {
#             "path" => "/readiness",
#             "port" => 8081,
#             "scheme" => "HTTP"
#           },
#           "initialDelaySeconds" => 3,
#           "timeoutSeconds" => 5
#         },
#         "args" => [
#           "--domain=#{node['kubernetes']['cluster_domain']}.",
#           "--dns-port=10053",
#           "--config-dir=/kube-dns-config",
#           "--nameservers=#{node['environment_v2']['set']['dns']['vip_lan']}",
#           "--kube-master-url=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
#           "--v=2"
#         ],
#         "env" => [
#           {
#             "name" => "PROMETHEUS_PORT",
#             "value" => "10055"
#           }
#         ],
#         "ports" => [
#           {
#             "containerPort" => 10053,
#             "name" => "dns-local",
#             "protocol" => "UDP"
#           },
#           {
#             "containerPort" => 10053,
#             "name" => "dns-tcp-local",
#             "protocol" => "TCP"
#           },
#           {
#             "containerPort" => 10055,
#             "name" => "metrics",
#             "protocol" => "TCP"
#           }
#         ],
#         "volumeMounts" => [
#           {
#             "name" => "kube-dns-config",
#             "mountPath" => "/kube-dns-config"
#           }
#         ]
#       },
#       {
#         "name" => "dnsmasq",
#         "image" => "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.2",
#         "livenessProbe" => {
#           "httpGet" => {
#             "path" => "/healthcheck/dnsmasq",
#             "port" => 10054,
#             "scheme" => "HTTP"
#           },
#           "initialDelaySeconds" => 60,
#           "timeoutSeconds" => 5,
#           "successThreshold" => 1,
#           "failureThreshold" => 5
#         },
#         "args" => [
#           "-v=2",
#           "-logtostderr",
#           "-configDir=/etc/k8s/dns/dnsmasq-nanny",
#           "-restartDnsmasq=true",
#           "--",
#           "-k",
#           "--cache-size=1000",
#           "--log-facility=-",
#           "--server=/#{node['kubernetes']['cluster_domain']}/127.0.0.1#10053",
#           "--server=/in-addr.arpa/127.0.0.1#10053",
#           "--server=/ip6.arpa/127.0.0.1#10053"
#         ],
#         "ports" => [
#           {
#             "containerPort" => 53,
#             "name" => "dns",
#             "protocol" => "UDP"
#           },
#           {
#             "containerPort" => 53,
#             "name" => "dns-tcp",
#             "protocol" => "TCP"
#           }
#         ],
#         "resources" => {
#           "requests" => {
#             "cpu" => "150m",
#             "memory" => "20Mi"
#           }
#         },
#         "volumeMounts" => [
#           {
#             "name" => "kube-dns-config",
#             "mountPath" => "/etc/k8s/dns/dnsmasq-nanny"
#           }
#         ]
#       },
#       {
#         "name" => "sidecar",
#         "image" => "gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.2",
#         "livenessProbe" => {
#           "httpGet" => {
#             "path" => "/metrics",
#             "port" => 10054,
#             "scheme" => "HTTP"
#           },
#           "initialDelaySeconds" => 60,
#           "timeoutSeconds" => 5,
#           "successThreshold" => 1,
#           "failureThreshold" => 5
#         },
#         "args" => [
#           "--v=2",
#           "--logtostderr",
#           "--probe=kubedns,127.0.0.1:10053,kubernetes.default.svc.#{node['kubernetes']['cluster_domain']},5,A",
#           "--probe=dnsmasq,127.0.0.1:53,kubernetes.default.svc.#{node['kubernetes']['cluster_domain']},5,A"
#         ],
#         "ports" => [
#           {
#             "containerPort" => 10054,
#             "name" => "metrics",
#             "protocol" => "TCP"
#           }
#         ],
#         "resources" => {
#           "requests" => {
#             "memory" => "20Mi",
#             "cpu" => "10m"
#           }
#         }
#       }
#     ],
#     "volumes" => [
#       {
#         "name" => "kube-dns-config",
#         "configMap" => {
#           "name" => "kube-dns",
#           "optional" => true
#         }
#       }
#     ]
#   }
# }
