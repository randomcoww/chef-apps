node.default['kube_master']['pods']['image'] = 'gcr.io/google_containers/hyperkube:v1.6.4'

node.default['kube_master']['pods']['apiserver'] = {
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
        "image" => node['kube_master']['pods']['image'],
        "command" => [
          "/hyperkube",
          "apiserver",
          "--bind-address=0.0.0.0",
          "--etcd-servers=#{node['kube_master']['etcd']['nodes']}",
          "--allow-privileged=true",
          "--service-cluster-ip-range=#{node['kube_master']['service_ip_range']}",
          "--secure-port=443",
          "--advertise-address=#{node['kube_master']['node_ip']}",
          "--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota",
          # "--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota",
          "--tls-cert-file=#{node['kube_master']['cert_path']}",
          "--tls-private-key-file=#{node['kube_master']['key_path']}",
          "--client-ca-file=#{node['kube_master']['ca_path']}",
          "--service-account-key-file=#{node['kube_master']['key_path']}",
          # "--runtime-config=extensions/v1beta1/networkpolicies=true",
          # "--anonymous-auth=false"
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
            "name" => "ssl-certs-kubernetes",
            "mountPath" => node['kube_master']['ssl_path'],
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
        "name" => "ssl-certs-kubernetes",
        "hostPath" => {
          "path" => node['kube_master']['ssl_path']
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
