include_recipe "minikube-pod::_kubelet_override"

node.default['kubelet']['static_pods']['etcd.yaml'] = {
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
          "--name",
          "etcd0",
          "--data-dir=/var/lib/etcd",
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
          "--bind-address=127.0.0.1",
          "--insecure-bind-address=0.0.0.0",
          "--secure-port=#{node['kubernetes']['secure_port']}",
          "--insecure-port=#{node['kubernetes']['insecure_port']}",
          "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
          "--etcd-servers=http://127.0.0.1:2379",
          "--admission-control=",
          "--allow-privileged=true"
        ],
        # "ports" => [
        #   {
        #     "protocol" => "TCP",
        #     "containerPort" => 8080,
        #     "hostPort" => 8080,
        #   },
        #   {
        #     "protocol" => "TCP",
        #     "containerPort" => 8443,
        #     "hostPort" => 8443,
        #   }
        # ],
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
        "image" => node['kubernetes']['hyperkube_image'],
        "command" => [
          "/hyperkube",
          "controller-manager",
          # "--cluster-name=#{node['kubernetes']['cluster_name']}",
          # "--cluster-cidr=#{node['kubernetes']['cluster_cidr']}",
          "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
          "--leader-elect=false",
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
      },
      {
        "name" => "kube-scheduler",
        "image" => node['kubernetes']['hyperkube_image'],
        "command" => [
          "/hyperkube",
          "scheduler",
          "--master=http://127.0.0.1:#{node['kubernetes']['insecure_port']}",
          "--leader-elect=false"
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
