node.default['kubelet']['static_pods']['kube-apiserver.yaml'] = {
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
          "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds",
          # "--basic-auth-file=#{node['kubernetes']['basic_auth_path']}",
          # "--token-auth-file=#{node['kubernetes']['token_file_path']}",
          "--allow-privileged=true"
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
        "name" => "kube-etcd",
        "image" => "quay.io/coreos/etcd:latest",
        "command" => [
          "--name",
          "etcd0",
          "--advertise-client-urls",
          "http://127.0.0.1:2379",
          "--listen-client-urls",
          "http://0.0.0.0:2379",
          "--initial-advertise-peer-urls",
          "http://127.0.0.1:2380",
          "--listen-peer-urls",
          "http://0.0.0.0:2380",
          "--initial-cluster-token",
          "etcd-cluster-1",
          "--initial-cluster",
          "etcd0=http://127.0.0.1:2380",
          "--initial-cluster-state",
          "new"
        ],
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

node.default['kubelet']['static_pods']['kube-controller-manager.yaml'] = {
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
          "--leader-elect=true",
          "--master=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
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
    ]
  }
}

node.default['kubelet']['static_pods']['kube-scheduler.yaml'] = {
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

node.default['kubelet']['static_pods']['kubernetes-dashboard.yaml'] = {
  "apiVersion" => "v1",
  "kind" => "Pod",
  "metadata" => {
    "name" => "kubernetes-dashboard",
    "namespace" => "kube-system",
    "labels" => {
      "k8s-app" => "kubernetes-dashboard"
    }
  },
  "spec" => {
    "hostNetwork" => true,
    "containers" => [
      {
        "name" => "kubernetes-dashboard",
        "image" => "gcr.io/google_containers/kubernetes-dashboard-amd64:v1.6.1",
        "command" => [
          "/dashboard",
          "--bind-address=0.0.0.0",
          "--insecure-bind-address=0.0.0.0",
          "--port=8443",
          "--apiserver-host=http://127.0.0.1:#{node['kubernetes']['insecure_port']}"
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
    ]
  }
}
