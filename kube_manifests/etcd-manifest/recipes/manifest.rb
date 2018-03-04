## --initial-cluster option for IP based config
etcd_initial_cluster = node['environment_v2']['set']['etcd']['hosts'].map { |e|
    "#{e}=https://#{node['environment_v2']['host'][e]['ip']['store']}:2380"
  }.join(",")


node['environment_v2']['set']['etcd']['hosts'].each do |host|
  ip = node['environment_v2']['host'][host]['ip']['store']

  etcd_environment = {
    "ETCD_NAME" => host,
    "ETCD_DATA_DIR" => "/var/lib/etcd",

    "ETCD_INITIAL_ADVERTISE_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_LISTEN_PEER_URLS" => "https://#{ip}:2380",
    "ETCD_ADVERTISE_CLIENT_URLS" => "https://#{ip}:2379",
    "ETCD_LISTEN_CLIENT_URLS" => "https://#{ip}:2379",
    "ETCD_INITIAL_CLUSTER" => etcd_initial_cluster,
    "ETCD_INITIAL_CLUSTER_STATE" => "new",
    "ETCD_INITIAL_CLUSTER_TOKEN" => node['etcd']['cluster_name'],

    "ETCD_TRUSTED_CA_FILE" => node['etcd']['ca_path'],
    "ETCD_CERT_FILE" => node['etcd']['cert_path'],
    "ETCD_KEY_FILE" => node['etcd']['key_path'],

    "ETCD_PEER_TRUSTED_CA_FILE" => node['etcd']['ca_peer_path'],
    "ETCD_PEER_CERT_FILE" => node['etcd']['cert_peer_path'],
    "ETCD_PEER_KEY_FILE" => node['etcd']['key_peer_path'],

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
              "mountPath" => "/etc/ssl/certs",
              "name" => "ssl-certs-host",
              "readOnly" => true
            },
            {
              "mountPath" => "/var/lib/etcd",
              "name" => "data-etcd-host",
              "readOnly" => false
            }
          ]
        }
      ],
      "volumes" => [
        {
          "name" => "ssl-certs-host",
          "hostPath" => {
            "path" => "/etc/ssl/certs"
          }
        },
        {
          "name" => "data-etcd-host",
          "hostPath" => {
            "path" => "/data/etcd"
          }
        }
      ]
    }
  }

  node.default['kubernetes']['static_pods'][host]['etcd'] = etcd_manifest
end
