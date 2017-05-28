node.default['kube_master']['pods'] = {
  'kube-apiserver.yaml' => {
    "kind" => "Pod",
    "apiVersion" => "v1",
    "metadata" => {
      "name" => "kube-apiserver"
    },
    "spec" => {
      "hostNetwork" => true,
      "containers" => [
        {
          "name" => "kube-apiserver",
          "image" => node['kube_master']['hyperkube_image'],
          "command" => [
            "/hyperkube",
            "apiserver",
            "--bind-address=127.0.0.1",
            "--address=127.0.0.1",
            "--service-cluster-ip-range=#{node['kube_master']['service_ip_range']}",
            "--etcd-servers=#{node['kube_master']['etcd']['nodes']}",
            "--tls-cert-file=#{node['kube_master']['cert_path']}",
            "--tls-private-key-file=#{node['kube_master']['key_path']}",
            "--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota",
            "--client-ca-file=#{node['kube_master']['ca_path']}",
            "--token-auth-file=#{node['kube_master']['token_file_path']}",
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
              "mountPath" => node['kube_master']['srv_path'],
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
            "path" => node['kube_master']['srv_path']
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
      "name" => "kube-controller-manager"
    },
    "spec" => {
      "hostNetwork" => true,
      "containers" => [
        {
          "name" => "kube-controller-manager",
          "image" => node['kube_master']['hyperkube_image'],
          "command" => [
            "/hyperkube",
            "controller-manager",
            "--cluster-name=#{node['kube_master']['cluster_name']}",
            "--cluster-cidr=#{node['kube_master']['service_ip_range']}",
            "--service-account-private-key-file=#{node['kube_master']['key_path']}",
            "--master=http://127.0.0.1:8080",
          ],
          "volumeMounts" => [
            {
              "name" => "srv-kubernetes",
              "mountPath" => node['kube_master']['srv_path'],
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
            "path" => node['kube_master']['srv_path'],
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
      "name" => "kube-scheduler"
    },
    "spec" => {
      "hostNetwork" => true,
      "containers" => [
        {
          "name" => "kube-scheduler",
          "image" => node['kube_master']['hyperkube_image'],
          "command" => [
            "/hyperkube",
            "scheduler",
            "--master=http://127.0.0.1:8080",
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
