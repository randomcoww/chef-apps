host_count = node['environment_v2']['set']['kube-master']['hosts'].length

# etcd_cluster = node['environment_v2']['set']['etcd']['hosts'].map { |e|
#     "https://#{node['environment_v2']['host'][e]['ip']['store']}:#{node['environment_v2']['port']['etcd']}"
#   }.join(",")
etcd_cluster = "https://127.0.0.1:#{node['environment_v2']['port']['etcd']}"

kube_scheduler_manifest = {
  "kind" => "Pod",
  "apiVersion" => "v1",
  "metadata" => {
    # "namespace" => "kube-system",
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
          "--config=#{::File.join(node['kubernetes']['kubernetes_path'], "kube-scheduler.yaml")}",
          "--v=2"
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
            "mountPath" => node['kubernetes']['kubernetes_path'],
            "readOnly" => true
          }
        ]
      }
    ],
    "volumes": [
      {
        "name" => "kubeconfig",
        "hostPath" => {
          "path" => node['kubernetes']['kubernetes_path']
        }
      }
    ]
  }
}


kube_apiserver_manifest = {
  "kind" => "Pod",
  "apiVersion" => "v1",
  "metadata" => {
    # "namespace" => "kube-system",
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
          "--secure-port=#{node['environment_v2']['port']['kube-master']}",
          "--allow-privileged=true",
          "--apiserver-count=#{host_count}",
          "--audit-log-maxage=30",
          "--audit-log-maxbackup=#{host_count}",
          "--audit-log-maxsize=100",
          "--audit-log-path=/var/log/audit.log",
          "--authorization-mode=Node,RBAC",
          "--bind-address=0.0.0.0",
          "--client-ca-file=#{::File.join(node['kubernetes']['kubernetes_path'], "ca.pem")}",
          "--enable-admission-plugins=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota",
          "--enable-swagger-ui=true",
          "--etcd-cafile=#{::File.join(node['kubernetes']['kubernetes_path'], "ca.pem")}",
          "--etcd-certfile=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes.pem")}",
          "--etcd-keyfile=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes-key.pem")}",
          "--etcd-servers=#{etcd_cluster}",
          "--event-ttl=1h",
          # "--experimental-encryption-provider-config=#{::File.join(node['kubernetes']['kubernetes_path'], "encryption-config.yaml")}",
          "--kubelet-certificate-authority=#{::File.join(node['kubernetes']['kubernetes_path'], "ca.pem")}",
          "--kubelet-client-certificate=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes.pem")}",
          "--kubelet-client-key=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes-key.pem")}",
          "--kubelet-https=true",
          "--runtime-config=api/all",
          "--service-account-key-file=#{::File.join(node['kubernetes']['kubernetes_path'], "service-account.pem")}",
          "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
          "--service-node-port-range=30000-32767",
          "--tls-cert-file=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes.pem")}",
          "--tls-private-key-file=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes-key.pem")}",
          "--storage-backend=etcd3",
          "--v=2"
        ],
        "volumeMounts" => [
          {
            "name" => "kubeconfig",
            "mountPath" => node['kubernetes']['kubernetes_path'],
            "readOnly" => true
          }
        ],
        "livenessProbe" => {
          "httpGet" => {
            "scheme" => "HTTP",
            "host" => "127.0.0.1",
            "port" => 8080,
            "path" => "/healthz"
          },
          "initialDelaySeconds" => 15,
          "timeoutSeconds" => 15
        }
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


kube_controller_manager_manifest = {
  "kind" => "Pod",
  "apiVersion" => "v1",
  "metadata" => {
    # "namespace" => "kube-system",
    "name" => "kube-controller-manager"
  },
  "spec" => {
    "hostNetwork" => true,
    "restartPolicy" => 'Always',
    "containers" => [
      {
        "name" => "kube-controller-manager",
        "image" => node['kube']['images']['hyperkube'],
        "command" => [
          "/hyperkube",
          "controller-manager",
          "--address=0.0.0.0",
          "--cluster-cidr=#{node['kubernetes']['cluster_cidr']}",
          "--allocate-node-cidrs=true",
          "--cluster-name=#{node['kubernetes']['cluster_name']}",
          "--cluster-signing-cert-file=#{::File.join(node['kubernetes']['kubernetes_path'], "ca.pem")}",
          "--cluster-signing-key-file=#{::File.join(node['kubernetes']['kubernetes_path'], "ca-key.pem")}",
          "--kubeconfig=#{::File.join(node['kubernetes']['kubernetes_path'], "kube-controller-manager.kubeconfig")}",
          "--leader-elect=true",
          "--root-ca-file=#{::File.join(node['kubernetes']['kubernetes_path'], "ca.pem")}",
          "--service-account-private-key-file=#{::File.join(node['kubernetes']['kubernetes_path'], "service-account-key.pem")}",
          "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
          "--use-service-account-credentials=true",
          "--v=2"
        ],
        "volumeMounts" => [
          {
            "name" => "kubeconfig",
            "mountPath" => node['kubernetes']['kubernetes_path'],
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
        "name" => "kubeconfig",
        "hostPath" => {
          "path" => node['kubernetes']['kubernetes_path']
        }
      }
    ]
  }
}


node['environment_v2']['set']['kube-master']['hosts'].each do |host|
  node.default['kubernetes']['static_pods'][host]['kube-apiserver_manifest'] = kube_apiserver_manifest
  node.default['kubernetes']['static_pods'][host]['kube-controller-manager_manifest'] = kube_controller_manager_manifest
  node.default['kubernetes']['static_pods'][host]['kube-scheduler_manifest'] = kube_scheduler_manifest
end
