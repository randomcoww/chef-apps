env_vars = node['environment_v2']['set']['kube-master']['vars']

domain = [
  node['environment_v2']['domain']['host'],
  node['environment_v2']['domain']['top']
].join('.')


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
        "image" => node['kube']['images']['flannel'],
        "command" => [
          "/opt/bin/flanneld",
          "--ip-masq",
          "--kube-subnet-mgr",
          "--kubeconfig-file=#{node['kubernetes']['client']['kubeconfig_path']}"
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
          },
          {
            "name" => "kubeconfig",
            "mountPath" => node['kubernetes']['client']['kubeconfig_path'],
            "readOnly" => true
          },
          {
            "mountPath": "/etc/ssl/certs",
            "name": "ssl-certs-host",
            "readOnly": true
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
          "path" => node['kubernetes']['client']['kubeconfig_path']
        }
      },
      {
        "name" => "ssl-certs-host",
        "hostPath" => {
          "path" => env_vars['ssl_path']
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
          "--kubeconfig=#{node['kubernetes']['client']['kubeconfig_path']}",
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
        },
        "volumeMounts": [
          {
            "name" => "kubeconfig",
            "mountPath" => node['kubernetes']['client']['kubeconfig_path'],
            "readOnly" => true
          },
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
        "name" => "kubeconfig",
        "hostPath" => {
          "path" => node['kubernetes']['client']['kubeconfig_path']
        }
      },
      {
        "name" => "ssl-certs-host",
        "hostPath" => {
          "path" => env_vars['ssl_path']
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
          "--kubeconfig=#{node['kubernetes']['client']['kubeconfig_path']}"
        ],
        "securityContext": {
          "privileged": true
        },
        "volumeMounts": [
          {
            "name" => "kubeconfig",
            "mountPath" => node['kubernetes']['client']['kubeconfig_path'],
            "readOnly" => true
          },
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
        "name" => "kubeconfig",
        "hostPath" => {
          "path" => node['kubernetes']['client']['kubeconfig_path']
        }
      },
      {
        "name" => "ssl-certs-host",
        "hostPath" => {
          "path" => env_vars['ssl_path']
        }
      }
    ]
  }
}

## --etcd-servers option
etcd_servers = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "https://#{node['environment_v2']['host'][e]['ip']['store']}:2379"
  }.join(",")


kube_haproxy_manifest = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "namespace" => "kube-system",
    "name" => "kube-haproxy"
  },
  "spec" => {
    "restartPolicy" => "Always",
    "hostNetwork" => true,
    "containers" => [
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
      },
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
          node['kubernetes']['client']['kubeconfig_path'],
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
            "mountPath" => node['kubernetes']['client']['kubeconfig_path'],
            "readOnly" => true
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
          "path" => node['kubernetes']['client']['kubeconfig_path']
        }
      }
    ]
  }
}


# kube_dns_manifest = {
#   "apiVersion" => "v1",
#   "kind" => "Pod",
#   "metadata" => {
#     "name" => "kube-dns",
#   },
#   "spec" => {
#     "hostNetwork" => true,
#     "volumes" => [
#       {
#         "name" => "kube-dns-config",
#         "emptyDir" => {}
#       }
#     ],
#     "containers" => [
#       {
#         "name" => "kubedns",
#         "image" => "gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.6",
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
#           "--nameservers=#{node['environment_v2']['set']['dns']['vip_lan']}",
#           "--domain=#{node['kubernetes']['cluster_domain']}.",
#           "--dns-port=10053",
#           "--config-dir=/kube-dns-config",
#           "--v=2",
#           "--kube-master-url=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
#         ],
#         "env" => [
#           {
#             "name" => "PROMETHEUS_PORT",
#             "value" => "10055"
#           }
#         ],
#         # "ports" => [
#         #   {
#         #     "containerPort" => 10053,
#         #     "name" => "dns-local",
#         #     "protocol" => "UDP"
#         #   },
#         #   {
#         #     "containerPort" => 10053,
#         #     "name" => "dns-tcp-local",
#         #     "protocol" => "TCP"
#         #   },
#         #   {
#         #     "containerPort" => 10055,
#         #     "name" => "metrics",
#         #     "protocol" => "TCP"
#         #   }
#         # ],
#         "volumeMounts" => [
#           {
#             "name" => "kube-dns-config",
#             "mountPath" => "/kube-dns-config"
#           }
#         ]
#       },
#       {
#         "name" => "dnsmasq",
#         "image" => "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.6",
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
#           "--no-negcache",
#           "--log-facility=-",
#           "--server=/#{node['kubernetes']['cluster_domain']}/127.0.0.1#10053",
#           "--server=/in-addr.arpa/127.0.0.1#10053",
#           "--server=/ip6.arpa/127.0.0.1#10053"
#         ],
#         # "ports" => [
#         #   {
#         #     "containerPort" => 53,
#         #     "name" => "dns",
#         #     "protocol" => "UDP"
#         #   },
#         #   {
#         #     "containerPort" => 53,
#         #     "name" => "dns-tcp",
#         #     "protocol" => "TCP"
#         #   }
#         # ],
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
#         "image" => "gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.6",
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
#           "--probe=kubedns,127.0.0.1:10053,kubernetes.default.svc.#{node['kubernetes']['cluster_domain']},5,SRV",
#           "--probe=dnsmasq,127.0.0.1:53,kubernetes.default.svc.#{node['kubernetes']['cluster_domain']},5,SRV"
#         ],
#         # "ports" => [
#         #   {
#         #     "containerPort" => 10054,
#         #     "name" => "metrics",
#         #     "protocol" => "TCP"
#         #   }
#         # ],
#         "resources" => {
#           "requests" => {
#             "memory" => "20Mi",
#             "cpu" => "10m"
#           }
#         }
#       }
#     ],
#     "dnsPolicy" => "Default"
#   }
# }
#
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
#           "--apiserver-host=http://127.0.0.1:#{node['kubernetes']['insecure_port']}"
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
  ip = node['environment_v2']['host'][host]['ip']['store']

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
      "initContainers" => [
        "name" => "kube-vault-writer",
        "image" => node['kube']['images']['vault_reader'],
        "args" => [
          "-r",
          "apiserver",
          "-c",
          "#{node['kubernetes']['internal_ssl_base_path']}.pem",
          "-k",
          "#{node['kubernetes']['internal_ssl_base_path']}-key.pem",
          "-a",
          "#{node['kubernetes']['internal_ssl_base_path']}-ca.pem",
          "-s",
          "https://haproxy.svc.internal:#{node['environment_v2']['port']['vault']}",
          "-o",
          node['kubernetes']['apiserver_ssl_base_path'],
          "-i",
          [
            '127.0.0.1',
            node['kubernetes']['cluster_service_ip'],
            ip,
            node['environment_v2']['set']['kube-master']['vip']['store'],
            node['environment_v2']['set']['kube-master']['vip']['lan'],
          ].join(','),
          "-n",
          [
            'kubernetes.default',
            [host, domain].join('.'),
            'kube-master.svc.internal'
          ].join(','),
          "-t",
          "3"
        ],
        "volumeMounts" => [
          {
            "name" => "ssl-certs-host",
            "mountPath" => "/etc/ssl/certs",
            "readOnly" => true
          },
          {
            "name" => "apiserver-certs",
            "mountPath" => node['kubernetes']['apiserver_ssl_path'],
            "readOnly" => false
          }
        ],
      ],
      "containers" => [
        {
          "name" => "kube-apiserver",
          "image" => node['kube']['images']['hyperkube'],
          "command" => [
            "/hyperkube",
            "apiserver",
            "--bind-address=0.0.0.0",
            "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds",
            "--insecure-bind-address=127.0.0.1",
            "--secure-port=#{node['kubernetes']['secure_port']}",
            "--insecure-port=#{node['kubernetes']['insecure_port']}",
            "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
            # "--etcd-servers=#{node['kube_manifests']['etcd']['etcd_servers']}",
            "--etcd-servers=#{etcd_servers}",
            "--etcd-cafile=#{node['kubernetes']['etcd_ssl_base_path']}-ca.pem",
            "--etcd-certfile=#{node['kubernetes']['etcd_ssl_base_path']}.pem",
            "--etcd-keyfile=#{node['kubernetes']['etcd_ssl_base_path']}-key.pem",
            "--tls-cert-file=#{node['kubernetes']['apiserver_ssl_base_path']}.pem",
            "--tls-private-key-file=#{node['kubernetes']['apiserver_ssl_base_path']}-key.pem",
            "--client-ca-file=#{node['kubernetes']['apiserver_ssl_base_path']}-ca.pem",
            "--service-account-key-file=#{node['kubernetes']['service_account_key_path']}",
            # "--basic-auth-file=#{node['kubernetes']['basic_auth_path']}",
            # "--token-auth-file=#{node['kubernetes']['token_file_path']}",
            "--allow-privileged=true"
          ],
          "volumeMounts" => [
            {
              "name" => "ssl-certs-host",
              "mountPath" => "/etc/ssl/certs",
              "readOnly" => true
            },
            {
              "name" => "apiserver-certs",
              "mountPath" => node['kubernetes']['apiserver_ssl_path'],
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
        },
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
            "--service-account-private-key-file=#{node['kubernetes']['service_account_key_path']}",
            "--root-ca-file=#{node['kubernetes']['apiserver_ssl_base_path']}-ca.pem",
            "--leader-elect=true",
            "--kubeconfig=#{node['kubernetes']['client']['kubeconfig_path']}"
          ],
          "volumeMounts" => [
            {
              "name" => "kubeconfig",
              "mountPath" => node['kubernetes']['client']['kubeconfig_path'],
              "readOnly" => true
            },
            {
              "name" => "ssl-certs-host",
              "mountPath" => "/etc/ssl/certs",
              "readOnly" => true
            },
            {
              "name" => "apiserver-certs",
              "mountPath" => node['kubernetes']['apiserver_ssl_path'],
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
            "path" => env_vars['ssl_path']
          }
        },
        {
          "name" => "etcd-certs",
          "emptyDir" => {}
        },
        {
          "name" => "apiserver-certs",
          "emptyDir" => {}
        },
        {
          "name" => "kubeconfig",
          "hostPath" => {
            "path" => node['kubernetes']['client']['kubeconfig_path']
          }
        }
      ]
    }
  }


  node.default['kubernetes']['static_pods'][host]['flannel'] = flannel_manifest
  node.default['kubernetes']['static_pods'][host]['kube-apiserver_manifest'] = kube_apiserver_manifest
  node.default['kubernetes']['static_pods'][host]['kube-scheduler_manifest'] = kube_scheduler_manifest
  node.default['kubernetes']['static_pods'][host]['kube-proxy_manifest'] = kube_proxy_manifest
  # node.default['kubernetes']['static_pods'][host]['kube-dashboard'] = kube_dashboard
  # node.default['kubernetes']['static_pods'][host]['kube_dns'] = kube_dns_manifest
  node.default['kubernetes']['static_pods'][host]['kube-haproxy_manifest'] = kube_haproxy_manifest
end
