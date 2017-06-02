node.default['kubernetes']['static_pods'] = {
  'kube-apiserver.yaml' => {
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
            "--secure-port=443",
            "--service-cluster-ip-range=#{node['kubernetes']['service_ip_range']}",
            "--etcd-servers=#{node['kubernetes']['etcd']['nodes']}",
            "--tls-cert-file=#{node['kubernetes']['cert_path']}",
            "--tls-private-key-file=#{node['kubernetes']['key_path']}",
            "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota,DefaultTolerationSeconds",
            "--client-ca-file=#{node['kubernetes']['ca_path']}",
            "--service-account-key-file=#{node['kubernetes']['key_path']}",
            # "--token-auth-file=#{node['kubernetes']['token_file_path']}",
            # "--allow-privileged=true"
          ],
          "ports" => [
            {
              "name" => "https",
              "hostPort" => 443,
              "containerPort" => 443
            },
            {
              "name" => "local",
              "hostPort" => 8080,
              "containerPort" => 8080
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
  },

  'kube-controller-manager.yaml' => {
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
            "--master=http://127.0.0.1:8080",
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
  },

  'kube-scheduler.yaml' => {
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
            "--master=http://127.0.0.1:8080",
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
}
