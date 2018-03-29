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
# etcd_servers = node['environment_v2']['set']['etcd']['hosts'].map { |e|
#     "https://#{node['environment_v2']['host'][e]['ip']['store']}:2379"
#   }.join(",")


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

service_domain = [
  node['environment_v2']['domain']['vip'],
  node['environment_v2']['domain']['top']
].join('.')


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
        "https://vault.#{service_domain}:#{node['environment_v2']['port']['vault']}",
        "-o",
        node['kubernetes']['apiserver_ssl_base_path'],
        "-i",
        (node['environment_v2']['set']['kube-master']['vip'].values + [
          '127.0.0.1',
          node['kubernetes']['cluster_service_ip'],
        ]).compact.join(','),
        "-n",
        [
          'kubernetes.default',
          ['*', service_domain].join('.')
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
          "--etcd-servers=https://haproxy.#{service_domain}:#{node['environment_v2']['port']['etcd']}",
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


node['environment_v2']['set']['kube-master']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['flannel'] = flannel_manifest
  node.default['kubernetes']['static_pods'][host]['kube-apiserver_manifest'] = kube_apiserver_manifest
  node.default['kubernetes']['static_pods'][host]['kube-scheduler_manifest'] = kube_scheduler_manifest
  node.default['kubernetes']['static_pods'][host]['kube-proxy_manifest'] = kube_proxy_manifest
  node.default['kubernetes']['static_pods'][host]['kube-haproxy_manifest'] = kube_haproxy_manifest
end
