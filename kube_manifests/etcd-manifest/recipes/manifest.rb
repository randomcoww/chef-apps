## --initial-cluster option for IP based config
etcd_initial_cluster = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "#{e}=https://#{node['environment_v2']['host'][e]['ip']['store']}:2380"
  }.join(",")

env_vars = node['environment_v2']['set']['etcd']['vars']


node['environment_v2']['set']['etcd']['hosts'].each do |host|
  ip = node['environment_v2']['host'][host]['ip']['store']

  etcd_environment = {
    "ETCD_NAME" => host,
    "ETCD_CERT_FILE" => ::File.join(node['kubernetes']['kubernetes_path'], "kubernetes.pem"),
    "ETCD_KEY_FILE" => ::File.join(node['kubernetes']['kubernetes_path'], "kubernetes-key.pem"),
    "ETCD_PEER_CERT_FILE" => ::File.join(node['kubernetes']['kubernetes_path'], "kubernetes.pem"),
    "ETCD_PEER_KEY_FILE" => ::File.join(node['kubernetes']['kubernetes_path'], "kubernetes-key.pem"),
    "ETCD_TRUSTED_CA_FILE" => ::File.join(node['kubernetes']['kubernetes_path'], "ca.pem"),
    "ETCD_PEER_TRUSTED_CA_FILE" => ::File.join(node['kubernetes']['kubernetes_path'], "ca.pem"),
    "ETCD_PEER_CLIENT_CERT_AUTH" => "true",
    "ETCD_CLIENT_CERT_AUTH" => "true",
    "ETCD_INITIAL_ADVERTISE_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_LISTEN_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_LISTEN_CLIENT_URLS" => "https://#{ip}:#{node['environment_v2']['port']['etcd']},https://127.0.0.1:#{node['environment_v2']['port']['etcd']}",
    "ETCD_ADVERTISE_CLIENT_URLS" => "https://#{ip}:#{node['environment_v2']['port']['etcd']}",
    "ETCD_INITIAL_CLUSTER_TOKEN" => node['kubernetes']['etcd_cluster_name'],
    "ETCD_INITIAL_CLUSTER" => etcd_initial_cluster,
    "ETCD_INITIAL_CLUSTER_STATE" => "new",
    "ETCD_DATA_DIR" => ::File.join(env_vars["etcd_path"], host),
    "ETCD_ENABLE_V2" => "false"
  }

  etcd_manifest = {
    "apiVersion" => "v1",
    "kind" => "Pod",
    "metadata" => {
      "name" => "kube-etcd",
      # "namespace" => "kube-system",
    },
    "spec" => {
      "restartPolicy" => "Always",
      "hostNetwork" => true,
      "containers" => [
        {
          "name" => "kube-etcd",
          "image" => node['kube']['images']['etcd'],
          # "command" => [
          #   "--name #{host}",
          #   "--cert-file=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes.pem")}"
          #   "--key-file=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes-key.pem")}"
          #   "--peer-cert-file=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes.pem")}"
          #   "--peer-key-file=#{::File.join(node['kubernetes']['kubernetes_path'], "kubernetes-key.pem")}"
          #   "--trusted-ca-file=#{::File.join(node['kubernetes']['kubernetes_path'], "ca.pem")}"
          #   "--peer-trusted-ca-file=#{::File.join(node['kubernetes']['kubernetes_path'], "ca.pem")}"
          #   "--peer-client-cert-auth"
          #   "--client-cert-auth"
          #   "--initial-advertise-peer-urls https://${INTERNAL_IP}:2380"
          #   "--listen-peer-urls https://${INTERNAL_IP}:2380"
          #   "--listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379"
          #   "--advertise-client-urls https://${INTERNAL_IP}:2379"
          #   "--initial-cluster-token #{node['kubernetes']['etcd_cluster_name']}"
          #   "--initial-cluster #{etcd_initial_cluster}"
          #   "--initial-cluster-state new"
          #   "--data-dir=#{::File.join(env_vars["etcd_path"], host)}"
          #   "--enable-v2=false"
          # ],
          "env" => etcd_environment.map { |k, v|
            {
              "name" => k,
              "value" => v
            }
          },
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
