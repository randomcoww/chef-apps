## --initial-cluster option for IP based config
etcd_initial_cluster = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "#{e}=https://#{node['environment_v2']['host'][e]['ip']['store']}:2380"
  }.join(",")

env_vars = node['environment_v2']['set']['etcd']['vars']


node['environment_v2']['set']['etcd']['hosts'].each do |host|
  ip = node['environment_v2']['host'][host]['ip']['store']

  etcd_environment = {
    "ETCD_NAME" => host,
    "ETCD_DATA_DIR" => ::File.join(env_vars["etcd_path"], host),

    "ETCD_INITIAL_ADVERTISE_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_LISTEN_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_ADVERTISE_CLIENT_URLS" => "https://#{ip}:#{node['environment_v2']['port']['etcd']}",
    "ETCD_LISTEN_CLIENT_URLS" => "https://#{ip}:#{node['environment_v2']['port']['etcd']},https://127.0.0.1:#{node['environment_v2']['port']['etcd']}",
    "ETCD_INITIAL_CLUSTER" => etcd_initial_cluster,
    "ETCD_INITIAL_CLUSTER_STATE" => "new",
    "ETCD_INITIAL_CLUSTER_TOKEN" => node['kubernetes']['etcd_cluster_name'],

    "ETCD_TRUSTED_CA_FILE" => ::File.join(node['kubernetes']['kubernetes_path'], "ca.pem"),
    "ETCD_CERT_FILE" => ::File.join(node['kubernetes']['kubernetes_path'], "kubernetes.pem"),
    "ETCD_KEY_FILE" => ::File.join(node['kubernetes']['kubernetes_path'], "kubernetes-key.pem"),

    "ETCD_PEER_TRUSTED_CA_FILE" => ::File.join(node['kubernetes']['kubernetes_path'], "ca.pem"),
    "ETCD_PEER_CERT_FILE" => ::File.join(node['kubernetes']['kubernetes_path'], "kubernetes.pem"),
    "ETCD_PEER_KEY_FILE" => ::File.join(node['kubernetes']['kubernetes_path'], "kubernetes-key.pem"),

    "ETCD_PEER_CLIENT_CERT_AUTH" => "true"
  }

  etcd_manifest = {
    "kind" => "Pod",
    "apiVersion" => "v1",
    "metadata" => {
      "name" => "kube-etcd",
      "namespace" => "kube-system",
    },
    "spec" => {
      "hostNetwork" => true,
      "containers" => [
        {
          "name" => "kube-etcd",
          "image" => node['kube']['images']['etcd'],
          "env" => etcd_environment.map { |k, v|
            {
              "name" => k,
              "value" => v
            }
          },
          "volumeMounts" => [
            {
              "name" => "kubeconfig",
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
          "name" => "kubeconfig",
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
