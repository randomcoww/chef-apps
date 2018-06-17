## --initial-cluster option for IP based config
etcd_initial_cluster = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "#{e}=https://#{node['environment_v2']['host'][e]['ip']['store']}:#{node['environment_v2']['port']['etcd-peer']}"
  }.join(",")

env_vars = node['environment_v2']['set']['etcd']['vars']


node['environment_v2']['set']['etcd']['hosts'].each do |host|
  ip = node['environment_v2']['host'][host]['ip']['store']

  etcd_manifest = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      "name" => "kube-etcd",
      "namespace" => "kube-system",
    },
    "spec" => {
      "restartPolicy" => "Always",
      "hostNetwork" => true,
      "containers" => [
        {
          "name" => "kube-etcd",
          "image" => node['kube']['images']['etcd'],
          "args" => [
            "/usr/local/bin/etcd",
            "--name=$(NODE_NAME)",
            "--cert-file=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes.pem")}",
            "--key-file=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes-key.pem")}",
            "--peer-cert-file=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes.pem")}",
            "--peer-key-file=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes-key.pem")}",
            "--trusted-ca-file=#{::File.join(node['kubernetes']['kubernetes_path'], "ca.pem")}",
            "--peer-trusted-ca-file=#{::File.join(node['kubernetes']['kubernetes_path'], "ca.pem")}",
            "--peer-client-cert-auth",
            "--client-cert-auth",
            "--initial-advertise-peer-urls=https://$(INTERNAL_IP):#{node['environment_v2']['port']['etcd-peer']}",
            "--listen-peer-urls=https://$(INTERNAL_IP):#{node['environment_v2']['port']['etcd-peer']}",
            "--listen-client-urls=https://$(INTERNAL_IP):#{node['environment_v2']['port']['etcd']},https://127.0.0.1:#{node['environment_v2']['port']['etcd']}",
            "--advertise-client-urls=https://$(INTERNAL_IP):2379",
            "--initial-cluster-token=#{node['kubernetes']['etcd_cluster_name']}",
            "--initial-cluster=#{etcd_initial_cluster}",
            "--initial-cluster-state=new",
            "--data-dir=#{::File.join(env_vars["etcd_path"], '$(NODE_NAME)')}",
            "--enable-v2=false",
          ],
          "env" => [
            {
              "name" => "INTERNAL_IP",
              "valueFrom" => {
                "fieldRef" => {
                  "fieldPath" => "status.hostIP"
                }
              }
            },
            {
              "name" => "NODE_NAME",
              "valueFrom" => {
                "fieldRef" => {
                  "fieldPath" => "spec.nodeName"
                }
              }
            }
          ],
          "volumeMounts" => [
            {
              "name" => "ssl-path",
              "mountPath" => node['kubernetes']['kubernetes_path'],
              "readOnly" => true
            },
            {
              "mountPath" => env_vars["etcd_path"],
              "name" => "data-etcd-host",
              "readOnly" => false
            }
          ]
        }
      ],
      "volumes" => [
        {
          "name" => "ssl-path",
          "hostPath" => {
            "path" => node['kubernetes']['kubernetes_path']
          }
        },
        {
          "name" => "data-etcd-host",
          "nfs" => {
            "server" => node['environment_v2']['set']['nfs']['vip']['store'],
            "path" => env_vars["mount_path"]
          }
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['etcd'] = etcd_manifest
end
