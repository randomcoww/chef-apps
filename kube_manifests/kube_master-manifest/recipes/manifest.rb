flannel_manifest = {
  "kind" => "Pod",
  "apiVersion" => "v1",
  "metadata" => {
    "name" => "kube-flannel-ds",
    "namespace" => "kube-system",
  },
  "spec" => {
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "kube-flannel",
        "image" => "quay.io/coreos/flannel:v0.9.0-amd64",
        "command" => [
          "/opt/bin/flanneld",
          "--ip-masq",
          "--kube-subnet-mgr",
          "--kube-api-url=http://127.0.0.1:#{node['kubernetes']['insecure_port']}"
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
            "mountPath" => "/run"
          },
          {
            "name" => "flannel-cfg",
            "mountPath" => "/etc/kube-flannel/"
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
      }
    ]
  }
}

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
          "--allocate-node-cidrs=true",
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
          "--etcd-servers=https://#{node['environment_v2']['set']['haproxy']['vip_lan']}:#{node['environment_v2']['haproxy']['etcd-client-ssl']['port']}",
          "--etcd-cafile=#{node['etcd']['ca_path']}",
          "--etcd-certfile=#{node['etcd']['cert_path']}",
          "--etcd-keyfile=#{node['etcd']['key_path']}",
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
        "name" => "ssl-certs-host",
        "hostPath" => {
          "path" => "/etc/ssl"
        }
      }
    ]
  }
}

kube_dns_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kube-dns",
  },
  "spec" => {
    "volumes" => [
      {
        "name" => "kube-dns-config",
        "emptyDir" => {}
      }
    ],
    "containers" => [
      {
        "name" => "kubedns",
        "image" => "gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.6",
        "resources" => {
          "limits" => {
            "memory" => "170Mi"
          },
          "requests" => {
            "cpu" => "100m",
            "memory" => "70Mi"
          }
        },
        "livenessProbe" => {
          "httpGet" => {
            "path" => "/healthcheck/kubedns",
            "port" => 10054,
            "scheme" => "HTTP"
          },
          "initialDelaySeconds" => 60,
          "timeoutSeconds" => 5,
          "successThreshold" => 1,
          "failureThreshold" => 5
        },
        "readinessProbe" => {
          "httpGet" => {
            "path" => "/readiness",
            "port" => 8081,
            "scheme" => "HTTP"
          },
          "initialDelaySeconds" => 3,
          "timeoutSeconds" => 5
        },
        "args" => [
          "--domain=#{node['kubernetes']['cluster_domain']}.",
          "--dns-port=10053",
          "--config-dir=/kube-dns-config",
          "--v=2",
          "--kube-master-url=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
        ],
        "env" => [
          {
            "name" => "PROMETHEUS_PORT",
            "value" => "10055"
          }
        ],
        "ports" => [
          {
            "containerPort" => 10053,
            "name" => "dns-local",
            "protocol" => "UDP"
          },
          {
            "containerPort" => 10053,
            "name" => "dns-tcp-local",
            "protocol" => "TCP"
          },
          {
            "containerPort" => 10055,
            "name" => "metrics",
            "protocol" => "TCP"
          }
        ],
        "volumeMounts" => [
          {
            "name" => "kube-dns-config",
            "mountPath" => "/kube-dns-config"
          }
        ]
      },
      {
        "name" => "dnsmasq",
        "image" => "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.6",
        "livenessProbe" => {
          "httpGet" => {
            "path" => "/healthcheck/dnsmasq",
            "port" => 10054,
            "scheme" => "HTTP"
          },
          "initialDelaySeconds" => 60,
          "timeoutSeconds" => 5,
          "successThreshold" => 1,
          "failureThreshold" => 5
        },
        "args" => [
          "-v=2",
          "-logtostderr",
          "-configDir=/etc/k8s/dns/dnsmasq-nanny",
          "-restartDnsmasq=true",
          "--",
          "-k",
          "--cache-size=1000",
          "--no-negcache",
          "--log-facility=-",
          "--server=/#{node['kubernetes']['cluster_domain']}/127.0.0.1#10053",
          "--server=/in-addr.arpa/127.0.0.1#10053",
          "--server=/ip6.arpa/127.0.0.1#10053"
        ],
        "ports" => [
          {
            "containerPort" => 53,
            "name" => "dns",
            "protocol" => "UDP"
          },
          {
            "containerPort" => 53,
            "name" => "dns-tcp",
            "protocol" => "TCP",
            "hostPort" => node['environment_v2']['haproxy']['kube-dns']
          }
        ],
        "resources" => {
          "requests" => {
            "cpu" => "150m",
            "memory" => "20Mi"
          }
        },
        "volumeMounts" => [
          {
            "name" => "kube-dns-config",
            "mountPath" => "/etc/k8s/dns/dnsmasq-nanny"
          }
        ]
      },
      {
        "name" => "sidecar",
        "image" => "gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.6",
        "livenessProbe" => {
          "httpGet" => {
            "path" => "/metrics",
            "port" => 10054,
            "scheme" => "HTTP"
          },
          "initialDelaySeconds" => 60,
          "timeoutSeconds" => 5,
          "successThreshold" => 1,
          "failureThreshold" => 5
        },
        "args" => [
          "--v=2",
          "--logtostderr",
          "--probe=kubedns,127.0.0.1:10053,kubernetes.default.svc.#{node['kubernetes']['cluster_domain']},5,SRV",
          "--probe=dnsmasq,127.0.0.1:53,kubernetes.default.svc.#{node['kubernetes']['cluster_domain']},5,SRV"
        ],
        "ports" => [
          {
            "containerPort" => 10054,
            "name" => "metrics",
            "protocol" => "TCP"
          }
        ],
        "resources" => {
          "requests" => {
            "memory" => "20Mi",
            "cpu" => "10m"
          }
        }
      }
    ],
    "dnsPolicy" => "Default"
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

node['environment_v2']['set']['kube-master']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['flannel.yaml'] = flannel_manifest
  node.default['kubernetes']['static_pods'][host]['kube-apiserver_manifest.yaml'] = kube_apiserver_manifest
  node.default['kubernetes']['static_pods'][host]['kube-controller-manager_manifest.yaml'] = kube_controller_manager_manifest
  node.default['kubernetes']['static_pods'][host]['kube-scheduler_manifest.yaml'] = kube_scheduler_manifest
  node.default['kubernetes']['static_pods'][host]['kube-proxy_manifest.yaml'] = kube_proxy_manifest
  # node.default['kubernetes']['static_pods'][host]['kube-dashboard.yaml'] = kube_dashboard
  # node.default['kubernetes']['static_pods'][host]['kube_dns.yaml'] = kube_dns_manifest
end
