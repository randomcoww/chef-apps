# node.default['kubernetes']['addons']['kubedns-serviceaccount.yaml'] = {
#   "apiVersion" => "v1",
#   "kind" => "ServiceAccount",
#   "metadata" => {
#     "labels" => {
#       "k8s-app" => "kube-dns",
#       "kubernetes.io/cluster-service" => "true",
#       "addonmanager.kubernetes.io/mode" => "Reconcile"
#     },
#     "name" => "kube-dns",
#     "namespace" => "kube-system"
#   }
# }

node.default['kubernetes']['addons']['kubedns-configmap.yaml'] = {
  "apiVersion" => "v1",
  "kind" => "ConfigMap",
  "metadata" => {
    "name" => "kube-dns",
    "namespace" => "kube-system",
    "labels" => {
      "k8s-app" => "kube-dns",
      "kubernetes.io/cluster-service" => "true",
      "addonmanager.kubernetes.io/mode" => "Reconcile"
    }
  },
  "data" => {
    "upstreamNameservers" => "[\"#{node['environment_v2']['set']['dns']['vip_lan']}\"]\n"
  }
}

node.default['kubernetes']['addons']['kubedns-controller.yaml'] = {
  "apiVersion" => "extensions/v1beta1",
  "kind" => "Deployment",
  "metadata" => {
    "name" => "kube-dns",
    "namespace" => "kube-system",
    "labels" => {
      "k8s-app" => "kube-dns",
      "kubernetes.io/cluster-service" => "true",
      "addonmanager.kubernetes.io/mode" => "Reconcile"
    }
  },
  "spec" => {
    "strategy" => {
      "rollingUpdate" => {
        "maxSurge" => "10%",
        "maxUnavailable" => 0
      }
    },
    "selector" => {
      "matchLabels" => {
        "k8s-app" => "kube-dns"
      }
    },
    "template" => {
      "metadata" => {
        "labels" => {
          "k8s-app" => "kube-dns"
        },
        "annotations" => {
          "scheduler.alpha.kubernetes.io/critical-pod" => ""
        }
      },
      "spec" => {
        "tolerations" => [
          {
            "key" => "CriticalAddonsOnly",
            "operator" => "Exists"
          }
        ],
        "volumes" => [
          {
            "name" => "kube-dns-config",
            "configMap" => {
              "name" => "kube-dns",
              "optional" => true
            }
          }
        ],
        "containers" => [
          {
            "name" => "kubedns",
            "image" => "gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.2",
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
              "--v=2"
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
            "image" => "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.2",
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
                "protocol" => "TCP"
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
            "image" => "gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.2",
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
              "--probe=kubedns,127.0.0.1:10053,kubernetes.default.svc.#{node['kubernetes']['cluster_domain']},5,A",
              "--probe=dnsmasq,127.0.0.1:53,kubernetes.default.svc.#{node['kubernetes']['cluster_domain']},5,A"
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
        "dnsPolicy" => "Default",
        # "serviceAccountName" => "kube-dns"
      }
    }
  }
}

node.default['kubernetes']['addons']['kubedns-svc.yaml'] = {
  "apiVersion" => "v1",
  "kind" => "Service",
  "metadata" => {
    "name" => "kube-dns",
    "namespace" => "kube-system",
    "labels" => {
      "k8s-app" => "kube-dns",
      "kubernetes.io/cluster-service" => "true",
      "addonmanager.kubernetes.io/mode" => "Reconcile",
      "kubernetes.io/name" => "KubeDNS"
    }
  },
  "spec" => {
    "selector" => {
      "k8s-app" => "kube-dns"
    },
    "clusterIP" => node['kubernetes']['cluster_dns_ip'],
    "ports" => [
      {
        "name" => "dns",
        "port" => 53,
        "protocol" => "UDP"
      },
      {
        "name" => "dns-tcp",
        "port" => 53,
        "protocol" => "TCP"
      }
    ]
  }
}

## dashboard

# node.default['kubernetes']['addons']['kube-dashboard-serviceaccount.yaml'] = {
#   "apiVersion" => "v1",
#   "kind" => "ServiceAccount",
#   "metadata" => {
#     "labels" => {
#       "k8s-app" => "kubernetes-dashboard",
#       "kubernetes.io/cluster-service" => "true",
#       "addonmanager.kubernetes.io/mode" => "Reconcile"
#     },
#     "name" => "kubernetes-dashboard",
#     "namespace" => "kube-system"
#   }
# }
#
# node.default['kubernetes']['addons']['kube-dashboard-rbac.yaml'] = {
#   "apiVersion" => "rbac.authorization.k8s.io/v1beta1",
#   "kind" => "ClusterRoleBinding",
#   "metadata" => {
#     "name" => "kubernetes-dashboard",
#     "labels" => {
#       "k8s-app" => "kubernetes-dashboard",
#       "kubernetes.io/cluster-service" => "true",
#       "addonmanager.kubernetes.io/mode" => "Reconcile"
#     }
#   },
#   "roleRef" => {
#     "apiGroup" => "rbac.authorization.k8s.io",
#     "kind" => "ClusterRole",
#     "name" => "cluster-admin"
#   },
#   "subjects" => [
#     {
#       "kind" => "ServiceAccount",
#       "name" => "kubernetes-dashboard",
#       "namespace" => "kube-system"
#     }
#   ]
# }

node.default['kubernetes']['addons']['kube-dashboard.yaml'] = {
  "kind" => "Deployment",
  "apiVersion" => "extensions/v1beta1",
  "metadata" => {
    "labels" => {
      "k8s-app" => "kubernetes-dashboard",
      "kubernetes.io/cluster-service" => "true",
      "addonmanager.kubernetes.io/mode" => "Reconcile"
    },
    "name" => "kubernetes-dashboard",
    "namespace" => "kube-system"
  },
  "spec" => {
    "replicas" => 1,
    "revisionHistoryLimit" => 10,
    "selector" => {
      "matchLabels" => {
        "k8s-app" => "kubernetes-dashboard"
      }
    },
    "template" => {
      "metadata" => {
        "labels" => {
          "k8s-app" => "kubernetes-dashboard"
        }
      },
      "spec" => {
        "containers" => [
          {
            "name" => "kubernetes-dashboard",
            "image" => "gcr.io/google_containers/kubernetes-dashboard-amd64:v1.6.1",
            "ports" => [
              {
                "containerPort" => 9090,
                "protocol" => "TCP"
              }
            ],
            "livenessProbe" => {
              "httpGet" => {
                "path" => "/",
                "port" => 9090
              },
              "initialDelaySeconds" => 30,
              "timeoutSeconds" => 30
            }
          }
        ],
        # "serviceAccountName" => "kubernetes-dashboard",
        "tolerations" => [
          {
            "key" => "node-role.kubernetes.io/master",
            "effect" => "NoSchedule"
          }
        ]
      }
    }
  }
}

node.default['kubernetes']['addons']['kube-dashboard-svc.yaml'] = {
  "kind" => "Service",
  "apiVersion" => "v1",
  "metadata" => {
    "labels" => {
      "k8s-app" => "kubernetes-dashboard",
      "kubernetes.io/cluster-service" => "true",
      "addonmanager.kubernetes.io/mode" => "Reconcile"
    },
    "name" => "kubernetes-dashboard",
    "namespace" => "kube-system"
  },
  "spec" => {
    "ports" => [
      {
        "port" => 80,
        "targetPort" => 9090
      }
    ],
    "selector" => {
      "k8s-app" => "kubernetes-dashboard"
    }
  }
}
